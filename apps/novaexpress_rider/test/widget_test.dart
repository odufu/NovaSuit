import 'package:flutter_test/flutter_test.dart';
import 'package:novaexpress_rider/main.dart';

void main() {
  testWidgets('NovaExpress Rider App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaExpressRiderApp());
    expect(find.byType(NovaExpressRiderApp), findsOneWidget);
  });
}
