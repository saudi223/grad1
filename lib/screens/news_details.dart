import 'package:flutter/material.dart';

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const NewsDetailScreen({required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool showFullContent = false;

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final content = article['content'] ?? '';
    final description = article['description'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(article['source']['name'] ?? 'News Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image'] != null)
              Image.network(
                article['image'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'] ?? '',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blueGrey,
                        child: Text(
                          article['source']['name'] != null &&
                              article['source']['name'].isNotEmpty
                              ? article['source']['name'][0].toUpperCase()
                              : '?',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        article['source']['name'] ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 20),
                  if (content.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showFullContent
                              ? content
                              : content.length > 200
                              ? content.substring(0, 200) + '...'
                              : content,
                          style: TextStyle(fontSize: 16),
                        ),
                        if (content.length > 200)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showFullContent = !showFullContent;
                              });
                            },
                            child: Text(
                              showFullContent ? 'عرض أقل' : 'عرض المزيد',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                      ],
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
