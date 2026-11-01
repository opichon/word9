import 'package:flutter_test/flutter_test.dart';
import 'package:word9/ui/word9_app.dart';

void main() {
  testWidgets('the app shell shows its title', (tester) async {
    await tester.pumpWidget(const Word9App());

    expect(find.text('word9'), findsOneWidget);
  });
}
