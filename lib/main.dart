import 'package:flutter/material.dart';
import 'api_service.dart';
import 'article_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Berita',
      debugShowCheckedModeBanner: false,
      home: NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> _articlesFuture;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _articlesFuture = ApiService().fetchArticles();

    _scrollController.addListener(() {
      if (_scrollController.offset >= 300 && !_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      } else if (_scrollController.offset < 300 && _showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articlesFuture = ApiService().fetchArticles();
    });
    await _articlesFuture;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Aplikasi Berita'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              final articles = snapshot.data!;
              if (articles.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(
                      height: 300,
                      child: Center(child: Text('Tidak ada berita')),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    child: ListTile(
                      leading: article.urlToImage != null &&
                              article.urlToImage!.isNotEmpty
                          ? Image.network(
                              article.urlToImage!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image),
                      title: Text(article.title),
                      subtitle: Text(
                        article.description ?? 'Tidak ada deskripsi',
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Tidak ada berita'),
              );
            }
          },
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.lightBlue,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}