# Android API levels that get an emulator. Leave a level empty to work it out,
# or set it to pin it, for example: just android_api_latest=37.0 setup-android
android_api_extra := "" # More levels, separated by spaces, such as one with a known bug.
android_api_latest := "" # Newest stable level that has a Google APIs image for this Mac's chip.
android_api_min := "" # The minSdkVersion that this version of Flutter sets.
android_api_target := "" # The targetSdkVersion that this version of Flutter sets.
android_device := "pixel_8"

# `default` comes first so that a bare `just` doesn't start the Android downloads.

# List the recipes.
default:
    @just --list

# Install Android emulator images and create a virtual device for each API level.
setup-android:
    #!/usr/bin/env bash
    set -euo pipefail

    die() { echo "error: $*" >&2; exit 1; }

    sdk="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
    sdkmanager="$sdk/cmdline-tools/latest/bin/sdkmanager"
    avdmanager="$sdk/cmdline-tools/latest/bin/avdmanager"
    [ -x "$sdkmanager" ] || die "Android command-line tools not found in $sdk. In Android Studio, install them from Settings > Languages & Frameworks > Android SDK > SDK Tools."

    case "$(uname -m)" in
      arm64) abi=arm64-v8a ;;
      x86_64) abi=x86_64 ;;
      *) die "unsupported chip: $(uname -m)" ;;
    esac

    # The app takes these levels from Flutter, so read them from the Flutter in use.
    flutter_level() {
      grep -q "$1 = flutter.$2" android/app/build.gradle.kts \
        || die "android/app/build.gradle.kts no longer sets $1 from Flutter: set android_api_${3} in the justfile"
      local root level
      root="$(flutter --version --machine 2>/dev/null | sed -n 's/.*"flutterRoot": *"\(.*\)".*/\1/p')"
      level="$(sed -n "s/.*val $2: Int = \([0-9][0-9]*\).*/\1/p" "$root/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt")"
      [ -n "$level" ] || die "couldn't read $2 from Flutter: set android_api_${3} in the justfile"
      echo "$level"
    }

    latest_level() {
      local level
      # The pattern leaves out previews (android-37.2-beta1) and extensions (android-36-ext19).
      level="$("$sdkmanager" --list 2>/dev/null \
        | grep -oE "system-images;android-[0-9]+(\.[0-9]+)?;google_apis;$abi" \
        | sed -E 's/.*android-([^;]+);.*/\1/' \
        | sort -V \
        | tail -n 1)"
      [ -n "$level" ] || die "couldn't find the latest Android image: set android_api_latest in the justfile"
      echo "$level"
    }

    min="{{ android_api_min }}"
    target="{{ android_api_target }}"
    latest="{{ android_api_latest }}"
    [ -n "$min" ] || min="$(flutter_level minSdk minSdkVersion min)"
    [ -n "$target" ] || target="$(flutter_level targetSdk targetSdkVersion target)"
    [ -n "$latest" ] || latest="$(latest_level)"

    levels="$(printf '%s\n' "$min" "$target" "$latest" {{ android_api_extra }} | sort -uV)"
    echo "API levels: min $min, target $target, latest $latest, extra: {{ if android_api_extra == "" { "none" } else { android_api_extra } }}"

    flutter doctor --android-licenses

    packages=()
    for level in $levels; do
      packages+=("system-images;android-$level;google_apis;$abi")
    done
    "$sdkmanager" emulator platform-tools "${packages[@]}"

    existing="$("$sdk/emulator/emulator" -list-avds 2>/dev/null || true)"
    for level in $levels; do
      name="word9_api${level%.0}"
      if grep -qx "$name" <<< "$existing"; then
        echo "$name already exists"
      else
        # avdmanager asks about a custom hardware profile even with a device set.
        echo no | "$avdmanager" create avd -n "$name" -d "{{ android_device }}" \
          -k "system-images;android-$level;google_apis;$abi"
      fi
    done

    echo
    echo "Start an emulator with: flutter emulators --launch word9_api${target%.0}"
