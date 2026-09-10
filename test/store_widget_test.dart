import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_store/main.dart';
import 'package:fake_store/core/network/api_exception.dart';
import 'package:fake_store/features/store/model/product.dart';
import 'package:fake_store/features/store/view/widgets/product_card.dart';
import 'store_test.dart' show TestRepository, shirt, ring;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final font = FontLoader('Urbanist')..addFont(rootBundle.load('assets/fonts/Urbanist.ttf'));
    await font.load();
  });
  Future<void> setSize(WidgetTester tester, {Size size = const Size(390, 844)}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('search, detail navigation, favorite and cart badge work together', (tester) async {
    await setSize(tester);
    await tester.pumpWidget(FakeStoreApp(repository: TestRepository(() async => [shirt, ring])));
    await tester.pumpAndSettle();
    expect(find.text('Andrew Ainsley'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'cotton');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(ProductCard), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Cotton Shirt'), findsOneWidget);
    expect(find.text('Silver Ring'), findsNothing);
    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Product Details'), findsOneWidget);
    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading, error, retry and empty are visible', (tester) async {
    await setSize(tester, size: const Size(390, 1400));
    final pending = Completer<List<Product>>();
    var calls = 0;
    await tester.pumpWidget(FakeStoreApp(repository: TestRepository(() {
      calls++;
      return calls == 1 ? pending.future : Future.value([]);
    })));
    await tester.pump();
    expect(find.text('Finding your next favorite…'), findsOneWidget);
    pending.completeError(const ApiException('Check your connection'));
    await tester.pumpAndSettle();
    expect(find.text('Check your connection'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'shirt');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    expect(calls, 2);
  });

  for (final width in [320.0, 430.0, 800.0]) {
    testWidgets('home and detail fit ${width.toInt()}px width', (tester) async {
      await setSize(tester, size: Size(width, 1200));
      await tester.pumpWidget(FakeStoreApp(repository: TestRepository(() async => [shirt])));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byType(ProductCard), 150, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(shirt.description), findsOneWidget);
    });
  }
}
