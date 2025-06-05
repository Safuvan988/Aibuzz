import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // TODO: Replace this with your actual API key from https://newsapi.org/register
  // The free tier allows up to 100 requests per day
  static const String _apiKey = 'f715fe3813104a5bbb810c1c0558ce7a';

  Future<List<Map<String, dynamic>>> getTopHeadlines({
    String? category,
    String? country = 'us',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      debugPrint('Fetching top headlines...');
      debugPrint('Parameters: category=$category, country=$country, page=$page, pageSize=$pageSize');
      
      final queryParams = {
        'apiKey': _apiKey,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        if (country != null) 'country': country,
        if (category != null) 'category': category,
      };

      final uri = Uri.parse('$_baseUrl/top-headlines').replace(queryParameters: queryParams);
      debugPrint('Request URL: $uri');

      final response = await http.get(uri);
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final articles = List<Map<String, dynamic>>.from(data['articles']);
          debugPrint('Successfully fetched ${articles.length} articles');
          return articles;
        } else {
          final error = 'API returned error: ${data['message']}';
          debugPrint(error);
          throw Exception(error);
        }
      } else {
        final error = 'Failed to load news: ${response.statusCode} - ${response.body}';
        debugPrint(error);
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getTopHeadlines: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Error fetching news: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchNews({
    required String query,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      debugPrint('Searching news for query: $query');
      debugPrint('Parameters: page=$page, pageSize=$pageSize');
      
      final queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        'sortBy': 'publishedAt',
      };

      final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: queryParams);
      debugPrint('Request URL: $uri');

      final response = await http.get(uri);
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final articles = List<Map<String, dynamic>>.from(data['articles']);
          debugPrint('Successfully fetched ${articles.length} search results');
          return articles;
        } else {
          final error = 'API returned error: ${data['message']}';
          debugPrint(error);
          throw Exception(error);
        }
      } else {
        final error = 'Failed to search news: ${response.statusCode} - ${response.body}';
        debugPrint(error);
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in searchNews: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Error searching news: $e');
    }
  }
} 