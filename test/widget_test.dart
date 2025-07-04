import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_scanner/main.dart';
import 'package:crypto_scanner/providers/app_provider.dart';

void main() {
  testWidgets('App starts with PIN screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Set PIN'), findsOneWidget);
    expect(find.text('Enter PIN'), findsNothing);
  });

  testWidgets('PIN input works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.tap(find.text('1'));
    await tester.pump();
    
    await tester.tap(find.text('2'));
    await tester.pump();
    
    await tester.tap(find.text('3'));
    await tester.pump();
    
    await tester.tap(find.text('4'));
    await tester.pump();

    expect(find.text('Confirm PIN'), findsOneWidget);
  });

  group('AppProvider tests', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    test('initial state is correct', () {
      expect(provider.isAuthenticated, false);
      expect(provider.isLoading, false);
      expect(provider.cryptocurrencies, isEmpty);
      expect(provider.error, isEmpty);
    });

    test('setPIN validates input', () async {
      expect(await provider.setPIN('1234'), true);
      expect(await provider.setPIN('12'), false);
      expect(await provider.setPIN('abcd'), false);
    });
  });
}
