import 'package:flutter_test/flutter_test.dart';

import 'package:waste_sorting_mvp/main.dart';

void main() {
  testWidgets('Loading screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WasteSortingMVP());

    // Verify that the loading screen shows WasteWise title
    expect(find.text('WasteWise'), findsOneWidget);
    expect(find.text('Sort Smarter. Live Greener.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
