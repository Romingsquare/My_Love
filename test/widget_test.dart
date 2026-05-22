import 'package:flutter_test/flutter_test.dart';
import 'package:chronos_archive/main.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const ChronosArchiveApp());
    expect(find.byType(ChronosArchiveApp), findsOneWidget);
  });
}
