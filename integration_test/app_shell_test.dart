import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word9/ui/word9_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: the app opens showing its title', (tester) async {
    await tester.pumpWidget(const Word9App());

    expect(find.text('word9'), findsOneWidget);
  });
}
