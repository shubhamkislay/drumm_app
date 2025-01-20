abstract class RemoteArticlesEvent{
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent{
  String category;
  GetArticles(this.category);
}