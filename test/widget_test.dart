import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';
import 'package:vocbuilder/presentation/screens/study/widgets/review_buttons.dart';
import 'package:vocbuilder/core/enums/review_rating.dart';

void main() {
  testWidgets('ReviewButtons triggers correct rating callbacks', (WidgetTester tester) async {
    ReviewRating? tappedRating;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewButtons(
            onRating: (rating) {
              tappedRating = rating;
            },
          ),
        ),
      ),
    );

    // Tap Again button
    await tester.tap(find.text('Again'));
    await tester.pumpAndSettle();
    expect(tappedRating, ReviewRating.again);

    // Tap Good button
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
    expect(tappedRating, ReviewRating.good);
  });
}
