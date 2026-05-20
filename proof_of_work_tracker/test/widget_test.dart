import 'package:flutter_test/flutter_test.dart';
import 'package:proof_of_work_tracker/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProofOfWorkApp());
    expect(find.text('LockedIn'), findsOneWidget);
  });
}
