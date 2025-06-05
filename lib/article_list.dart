import 'package:aibuzz/provider/bookmark_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArticleListView extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final Function(Map<String, dynamic>, BuildContext) onTap;
  final String Function(String) formatDateDMY;
  final Future<void> Function()? onRefresh;

  const ArticleListView({
    Key? key,
    required this.articles,
    required this.onTap,
    required this.formatDateDMY,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          final url = article['url'];
          final imageUrl = article['urlToImage'];
          final title = article['title'] ?? "No Title";
          final description = article['description'] ?? "No Description";
          final source = article['source']?['name'] ?? "Unknown";
          final publishedAt = article['publishedAt'] ?? "";

          return GestureDetector(
            onTap: () => onTap(article, context),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: theme.cardColor,
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: theme.iconTheme.color,
                            ),
                          );
                        },
                      )
                          : Container(
                        width: 100,
                        height: 100,
                        color: theme.cardColor,
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                                ),
                              ),
                              Consumer<BookmarkProvider>(
                                builder: (context, bookmarkProvider, child) {
                                  return IconButton(
                                    icon: Icon(
                                      bookmarkProvider.isBookmarked(url)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: bookmarkProvider.isBookmarked(url)
                                          ? theme.colorScheme.primary
                                          : theme.iconTheme.color,
                                    ),
                                    onPressed: () =>
                                        bookmarkProvider.toggleBookmark(url),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  source,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: theme.iconTheme.color,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  formatDateDMY(publishedAt),
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
