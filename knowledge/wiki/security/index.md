[Home](../../index.md) › Security

# Security

Threat model and the controls that address it - credential storage, authentication and token handling, transport, and permissions. Covers where secrets live, who can reach what, and the decisions behind each boundary.

## Controls

- [Network Posture](network-posture.md) - word9 makes no network requests and holds no user data: how that is required, what enforces it on each platform, and what the planned links change.
- [Supply-chain Controls](supply-chain-controls.md) - What controls what enters the repository and builds: pinned actions, workflow token scopes, a checksummed word source, and where signing secrets are planned to live.
