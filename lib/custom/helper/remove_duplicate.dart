import '../../model/article.dart';

class RemoveDuplicate {
  static List<Article> removeDuplicateArticles(List<Article> articles) {
    List<Article> uniqueArticles = [];

    for (var article in articles) {
      // Check if the article's description already exists in the uniqueArticles list
      bool exists = uniqueArticles.any((element) =>
      element.source == article.source && element.title == article.title && element.url == article.url);

      if (!exists) {
        uniqueArticles.add(article);
      }
    }

    return uniqueArticles;
  }

  static String removeStopWordsAndGetTopic(String sentence) {
    final stopWords = [
      'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from', 'has',
      'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the', 'to', 'was',
      'were', 'will', 'with'
    ];

    final words = sentence.toLowerCase().split(' ');
    final keywords = words.where((word) => !stopWords.contains(word)).toList();
    String topic = keywords.join(" ");

    return topic;
  }

  static String removeTitleSource(String title){
    List<String>? titleList =
    title.split('-');
    String? finalTitle = titleList![0] ?? "";
    int titleLength = titleList?.length ?? 0;
    for (int i = 1; i < titleLength - 1; i++) {
      finalTitle = "${finalTitle}-${titleList![i]}";
    }
    return finalTitle??title;
  }
}
