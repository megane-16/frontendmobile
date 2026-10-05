// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:driveflow1/main.dart';
import 'package:driveflow1/provider/auth_provider.dart';
import 'package:driveflow1/views/login_view.dart';

void main() {
  testWidgets('App renders LoginView initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(LoginView), findsOneWidget);
  });
}
