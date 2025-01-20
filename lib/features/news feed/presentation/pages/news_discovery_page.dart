import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsDiscoveryPage extends StatelessWidget {
  const NewsDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (context) => s1()..add(GetArticles("For You")),
      child: Scaffold(
        body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            String result = "News Discovery";
            if(state is RemoteArticlesLoading) {
              result = "Fetching articles...";
            } else if(state is RemoteArticlesFetched) result = "${state.articleEntityList?.elementAt(0).title} articles fetched";

            return Center(
              child: Text(result),
            );
          },
        ),
      ),
    );
  }
}
