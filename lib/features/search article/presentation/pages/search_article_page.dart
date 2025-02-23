// lib/features/news_feed/presentation/pages/search_page.dart
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_card.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_bloc.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_event.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_state.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class SearchArticlePage extends StatelessWidget {
  final List<BandEntity> bands;
  final DrummerEntity drummerEntity;
  const SearchArticlePage(
      {super.key, required this.bands, required this.drummerEntity});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Article Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                analytics.logEvent(
                  name: 'search_article',
                  parameters: <String, Object>{
                    'query': query,
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );

                context
                    .read<SearchArticleBloc>()
                    .add(SearchQueryChanged(query: query));
              },
              decoration: const InputDecoration(
                labelText: 'Search articles',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchArticleBloc, SearchArticleState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  if (state.articles.isEmpty) {
                    return const Center(child: Text('No articles found'));
                  }
                  return ListView.builder(
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) {
                      final article = state.articles[index];

                      return ArticleItemCard(article: article, bands: bands, drummerEntity: drummerEntity);
                      return ListTile(
                        title: Text(article.title ?? 'No Title'),
                        subtitle: Text(article.description ?? ''),
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('Enter a search term'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
