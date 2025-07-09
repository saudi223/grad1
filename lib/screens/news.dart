import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news_details.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  bool isLoading = false;
  bool hasMore = true;
  int maxResults = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNews();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasMore) {
        fetchNews();
      }
    });
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://gnews.io/api/v4/top-headlines?country=eg&category=health&max=$maxResults&apikey=6c9d2e4ee36d217417c2c10194183c25'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newArticles = data['articles'] ?? [];

        // Check if new articles added
        if (newArticles.length > articles.length) {
          setState(() {
            articles = newArticles;
            maxResults += 10;
            isLoading = false;
          });
        } else {
          // No more data
          setState(() {
            hasMore = false;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health News'),
      ),
      body: articles.isEmpty && isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= articles.length) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          }

          final article = articles[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NewsDetailScreen(article: article),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        article['image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? '',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blueGrey,
                              child: Text(
                                article['source']['name'] != null &&
                                    article['source']['name']
                                        .isNotEmpty
                                    ? article['source']['name'][0]
                                    .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                article['source']['name'] ?? '',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
