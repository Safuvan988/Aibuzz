import 'package:aibuzz/provider/bookmark_provider.dart';
import 'package:aibuzz/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'article_list.dart';
import 'authentication/loginpage.dart';
import 'news_details.dart';
import 'main.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> articles = [];
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  final NewsService _newsService = NewsService();
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    debugPrint('NewsFeedPage: Initializing...');
    _tabController = TabController(length: 2, vsync: this);
    _loadNews();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      debugPrint('NewsFeedPage: Search query changed to: $_searchQuery');
      if (_searchQuery.isNotEmpty) {
        _searchNews();
      } else {
        _loadNews();
      }
    });
  }

  Future<void> _loadNews() async {
    if (_isLoading || !_hasMoreData) {
      debugPrint('NewsFeedPage: Skipping _loadNews - isLoading: $_isLoading, hasMoreData: $_hasMoreData');
      return;
    }

    debugPrint('NewsFeedPage: Loading news...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('NewsFeedPage: Fetching top headlines for page $_currentPage');
      final newArticles = await _newsService.getTopHeadlines(
        page: _currentPage,
        pageSize: 20,
      );

      debugPrint('NewsFeedPage: Received ${newArticles.length} articles');
      setState(() {
        if (_currentPage == 1) {
          articles = newArticles;
          debugPrint('NewsFeedPage: Reset articles list with ${articles.length} items');
        } else {
          articles.addAll(newArticles);
          debugPrint('NewsFeedPage: Added ${newArticles.length} articles to existing list. Total: ${articles.length}');
        }
        _hasMoreData = newArticles.isNotEmpty;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('NewsFeedPage: Error loading news: $e');
      debugPrint('NewsFeedPage: Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchNews() async {
    if (_searchQuery.isEmpty) {
      debugPrint('NewsFeedPage: Empty search query, loading top headlines instead');
      _loadNews();
      return;
    }

    debugPrint('NewsFeedPage: Searching news for query: $_searchQuery');
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      debugPrint('NewsFeedPage: Fetching search results for page $_currentPage');
      final searchResults = await _newsService.searchNews(
        query: _searchQuery,
        page: _currentPage,
        pageSize: 20,
      );

      debugPrint('NewsFeedPage: Received ${searchResults.length} search results');
      setState(() {
        articles = searchResults;
        _hasMoreData = searchResults.isNotEmpty;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('NewsFeedPage: Error searching news: $e');
      debugPrint('NewsFeedPage: Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNews() async {
    debugPrint('NewsFeedPage: Refreshing news...');
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _loadNews();
  }

  String formatDateDMY(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  void openDetailedPage(Map<String, dynamic> article, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailPage(article: article)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterArticles(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((article) {
      final title = (article['title'] ?? '').toString().toLowerCase();
      final description = (article['description'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshNews,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading news...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No articles found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Pull down to refresh',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _loadNews();
              },
              icon: Icon(Icons.clear),
              label: Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    if (_isLoading && articles.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget(_error!);
    }

    if (articles.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              _hasMoreData &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (_searchQuery.isEmpty) {
              _loadNews();
            } else {
              _searchNews();
            }
          }
          return true;
        },
        child: Stack(
          children: [
            ArticleListView(
              articles: articles,
              onTap: openDetailedPage,
              formatDateDMY: formatDateDMY,
              onRefresh: _refreshNews,
            ),
            if (_isLoading && articles.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading more...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NewsFeedPage: Building with ${articles.length} articles, isLoading: $_isLoading, error: $_error');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'News Feed',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => Row(
                children: [
                  Icon(
                    themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.iconTheme.color,
                  ),
                  Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (val) => themeProvider.toggleTheme(),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: theme.iconTheme.color),
                    onPressed: () async {
                      bool? confirm = await showCustomLogoutDialog(context);
                      if (confirm == true) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('email');
                        await prefs.remove('password');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'All Articles'),
                    Tab(text: 'Bookmarks'),
                  ],
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                  indicatorColor: theme.colorScheme.primary,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                      prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: theme.iconTheme.color),
                              onPressed: () {
                                _searchController.clear();
                                _loadNews();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 1,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [

            _buildNewsList(),

            Consumer<BookmarkProvider>(
              builder: (context, bookmarkProvider, child) {
                final bookmarkedArticles = articles
                    .where((article) =>
                        bookmarkProvider.isBookmarked(article['url']))
                    .toList();
                final filteredBookmarks = _filterArticles(bookmarkedArticles);
                
                if (filteredBookmarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No bookmarked articles yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Articles you bookmark will appear here',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ArticleListView(
                  articles: filteredBookmarks,
                  onTap: openDetailedPage,
                  formatDateDMY: formatDateDMY,
                  onRefresh: _refreshNews,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<bool?> showCustomLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {

        final theme = Theme.of(context);
        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          elevation: 8,

          backgroundColor: theme.dialogBackgroundColor,

          title: Text(
            "Log Out",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Are you sure you want to log out of your account?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              child: Text(
                "Cancel",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 0,
              ),
              child: Text(
                "Log Out",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
