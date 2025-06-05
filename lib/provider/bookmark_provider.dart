import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider class to manage bookmarked articles
class BookmarkProvider extends ChangeNotifier {
  Set<String> _bookmarkedUrls = {};
  String? _currentUserEmail;
  static const String _bookmarksKeyPrefix = 'bookmarked_urls_';

  Set<String> get bookmarkedUrls => _bookmarkedUrls;
  String? get currentUserEmail => _currentUserEmail;

  // Get the storage key for the current user
  String get _storageKey => _currentUserEmail != null 
      ? '$_bookmarksKeyPrefix${_currentUserEmail!}'
      : _bookmarksKeyPrefix;

  // Set the current user and load their bookmarks
  Future<void> setCurrentUser(String? email) async {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      await loadBookmarks();
    }
  }

  // Load bookmarks for the current user
  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_storageKey) ?? [];
    _bookmarkedUrls = bookmarks.toSet();
    notifyListeners();
  }

  // Clear bookmarks for the current user
  Future<void> clearBookmarks() async {
    _bookmarkedUrls.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> toggleBookmark(String url) async {
    if (_currentUserEmail == null) {
      debugPrint('Cannot bookmark: No user is logged in');
      return;
    }

    if (_bookmarkedUrls.contains(url)) {
      _bookmarkedUrls.remove(url);
    } else {
      _bookmarkedUrls.add(url);
    }
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _bookmarkedUrls.toList());
    
    notifyListeners();
  }

  bool isBookmarked(String url) => _bookmarkedUrls.contains(url);
}




