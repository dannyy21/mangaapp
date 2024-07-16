import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class ChapterDetailPage extends StatelessWidget {
  final Map<String, dynamic> chapter;

  ChapterDetailPage({required this.chapter});

  Future<List<String>> fetchChapterPages(String chapterId) async {
    final response = await http.get(Uri.parse('https://api.mangadex.org/at-home/server/$chapterId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var baseUrl = data['baseUrl'];
      var chapterHash = data['chapter']['hash'];
      var pageArray = data['chapter']['data'] as List;
      List<String> pageUrls = pageArray.map((page) {
        return '$baseUrl/data/$chapterHash/$page';
      }).toList();
      return pageUrls;
    } else {
      throw Exception('Failed to load chapter pages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${chapter['chapter']}'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchChapterPages(chapter['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pages available'));
          }

          List<String> pages = snapshot.data!;
          return ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      color: Colors.white,
                    ),
                  ),
                  Image.network(
                    pages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.error));
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
