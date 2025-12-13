import 'package:dicoding_story/ui/detail/view_models/story_detail_pro_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SheetExtent Provider', () {
    test('initial state is 0.25', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(sheetExtentProvider);
      expect(state, 0.25);
    });

    test('update sets new extent value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sheetExtentProvider.notifier);

      // Initial check
      expect(container.read(sheetExtentProvider), 0.25);

      // Update value
      notifier.update(0.5);
      expect(container.read(sheetExtentProvider), 0.5);

      // Update again
      notifier.update(0.8);
      expect(container.read(sheetExtentProvider), 0.8);
    });
  });
}
