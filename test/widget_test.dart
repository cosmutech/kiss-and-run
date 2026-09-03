import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiss_and_run/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Kiss & Run smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KissAndRunApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('KISS & RUN'), findsOneWidget);
  });
}
