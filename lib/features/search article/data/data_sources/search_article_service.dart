// lib/features/news_feed/data/datasources/search_article_service.dart

import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:typesense/typesense.dart';
class SearchArticleService {
  late final Client _client;

  // Constructor that sets up the Typesense client with your configuration.
  SearchArticleService() {
    final config = Configuration(
      'kifdsI1wUYqfWiSChRNLKQUxMmyGQNfK', // Search Only API Key.
      nodes: {
        Node(
          Protocol.https, // Use HTTPS for secure connection.
          '5p7wfikze8r62l3bp-1.a1.typesense.net',
          port: 443,
        ),
      },
      numRetries: 3, // Total of 4 attempts (1 original + 3 retries).
      connectionTimeout: const Duration(seconds: 2),
    );
    _client = Client(config);
  }

  /// Searches for articles using the given [query] by invoking the preset "listing_view".
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final searchParams = {
        'preset': 'stories_search',
        'q': query,
      };

      // Use the Typesense client to search within the 'articles' collection.
      final result = await _client
          .collection('stories')
          .documents
          .search(searchParams);

      // The response is expected to have a 'hits' key containing the search results.
      final List<dynamic> hits = result['hits'] as List<dynamic>;
      return hits
          .map((hit) =>
          ArticleModel.fromJson(hit['document'] as Map<String, dynamic>))
          .toList();
    }catch(e){
      print("Error: $e");
      return [];
    }
  }
}
