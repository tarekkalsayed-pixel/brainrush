import 'package:flutter_test/flutter_test.dart';

import 'package:brainrush/main.dart';

void main() {
  testWidgets('Home screen shows BrainRush start button', (tester) async {
    await tester.pumpWidget(const BrainRushApp());

    expect(find.text('BrainRush'), findsOneWidget);
    expect(find.text('60-second brain challenge'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
