abstract class RemoteArticlesEvent{
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent{
  final String category;
  const GetArticles(this.category);
}