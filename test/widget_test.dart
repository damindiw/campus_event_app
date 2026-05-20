import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event_app/main.dart';

void main() {
  testWidgets('Verify app initializes successfully', (WidgetTester tester) async {
    // Builds our app and triggers a frame.
    await tester.pumpWidget(const CampusEventApp());
  });
}