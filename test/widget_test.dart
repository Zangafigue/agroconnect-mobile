import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agroconnect_bf/main.dart';

void main() {
  testWidgets('Initial load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AgroConnectApp()));

    // Verify that our app name is present (placeholder check)
    // expect(find.text('Connexion'), findsOneWidget);
  });
}
