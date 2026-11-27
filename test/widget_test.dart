import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganagaseva/main.dart';

void main() {
  testWidgets('Ganagaseva app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GanagasevaApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(GanagasevaApp), findsOneWidget);
  });
}
