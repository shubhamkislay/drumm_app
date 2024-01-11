import 'package:flutter/material.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/model/article.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'bottom_sheet.dart';

class AISummary {
  static Future<String> getNewsSummary(String? newsArticle) async {
    final apiKey =
        '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'; // Replace with your ChatGPT API key
    final apiUrl = 'https://api.openai.com/v1/completions';

    final requestBody = {
      "model": "gpt-3.5-turbo-instruct",
      'prompt': 'Summarize the news: $newsArticle',
      'max_tokens': 200, // Adjust the summary length as needed
      'temperature':
          0.7, // Adjust the temperature for generating diverse responses
      'n': 1, // Number of responses to get
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data['choices'][0]['text'].toString();
      print(summary);
      return summary;
    } else {
      print('Failed to get news summary. Error: ${response.body}');
      return "There seems to be an error while summarizing this article.\nPlease try again later.";
    }
  }
  static void showBottomSheet(BuildContext context, Article article, Color bgColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
          child: BottomSheetContent(article: article, bgColor: bgColor,),
        );
      },
    );
  }
}
