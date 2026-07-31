import 'package:flutter_test/flutter_test.dart';
import 'package:novasuite_admin/main.dart';

void main() {
  testWidgets('NovaSuite Admin App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaSuiteAdminApp());
    expect(find.byType(NovaSuiteAdminApp), findsOneWidget);
  });
}
