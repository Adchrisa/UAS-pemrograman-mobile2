import 'package:flutter_test/flutter_test.dart';
import 'package:ecohelper/services/bookmark_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Bookmark Service Tests', () {
    setUp(() async {
      // Reset shared preferences untuk setiap test
      SharedPreferences.setMockInitialValues({});
      await BookmarkService.clearAll();
    });

    test('Initially no bookmarks exist', () async {
      final bookmarks = await BookmarkService.getAll();
      expect(bookmarks.isEmpty, true);
    });

    test('Can add a bookmark', () async {
      await BookmarkService.toggle('article_1');
      final bookmarks = await BookmarkService.getAll();
      
      expect(bookmarks.contains('article_1'), true);
      expect(bookmarks.length, 1);
    });

    test('Can check if article is bookmarked', () async {
      await BookmarkService.toggle('article_1');
      final isBookmarked = await BookmarkService.isBookmarked('article_1');
      
      expect(isBookmarked, true);
    });

    test('Toggle removes bookmark if already exists', () async {
      // Add bookmark
      await BookmarkService.toggle('article_1');
      var bookmarks = await BookmarkService.getAll();
      expect(bookmarks.contains('article_1'), true);

      // Toggle to remove
      await BookmarkService.toggle('article_1');
      bookmarks = await BookmarkService.getAll();
      expect(bookmarks.contains('article_1'), false);
    });

    test('Can add multiple bookmarks', () async {
      await BookmarkService.toggle('article_1');
      await BookmarkService.toggle('article_2');
      await BookmarkService.toggle('article_3');
      
      final bookmarks = await BookmarkService.getAll();
      expect(bookmarks.length, 3);
      expect(bookmarks.contains('article_1'), true);
      expect(bookmarks.contains('article_2'), true);
      expect(bookmarks.contains('article_3'), true);
    });

    test('Can clear all bookmarks', () async {
      await BookmarkService.toggle('article_1');
      await BookmarkService.toggle('article_2');
      
      var bookmarks = await BookmarkService.getAll();
      expect(bookmarks.length, 2);

      await BookmarkService.clearAll();
      bookmarks = await BookmarkService.getAll();
      expect(bookmarks.isEmpty, true);
    });

    test('Notifier updates when bookmark changes', () async {
      expect(BookmarkService.notifier.value.isEmpty, true);

      await BookmarkService.toggle('article_1');
      expect(BookmarkService.notifier.value.contains('article_1'), true);

      await BookmarkService.toggle('article_1');
      expect(BookmarkService.notifier.value.isEmpty, true);
    });

    test('isBookmarked returns correct state', () async {
      final notBookmarked = await BookmarkService.isBookmarked('article_1');
      expect(notBookmarked, false);

      await BookmarkService.toggle('article_1');
      final isBookmarked = await BookmarkService.isBookmarked('article_1');
      expect(isBookmarked, true);
    });

    test('Can toggle same article multiple times', () async {
      // Add
      await BookmarkService.toggle('article_1');
      expect(await BookmarkService.isBookmarked('article_1'), true);

      // Remove
      await BookmarkService.toggle('article_1');
      expect(await BookmarkService.isBookmarked('article_1'), false);

      // Add again
      await BookmarkService.toggle('article_1');
      expect(await BookmarkService.isBookmarked('article_1'), true);
    });
  });
}
