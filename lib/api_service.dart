import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';

class ApiService {
  final String _apiKey = '441ff71a9665497b90e64000af28af27';

  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=apple&sortBy=popularity&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List articles = json['articles'];

      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil berita');
    }
  }
}