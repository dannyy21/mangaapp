import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mangaapp/page/manga_detail_page.dart';

void main() {
  runApp(const MangaApp());
}

class MangaApp extends StatelessWidget {
  const MangaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MangaHomePage(),
    );
  }
}

class MangaHomePage extends StatefulWidget {
  @override
  _MangaHomePageState createState() => _MangaHomePageState();
}

class _MangaHomePageState extends State<MangaHomePage> {
  List mangaList = [];

  @override
  void initState() {
    super.initState();
    fetchMangaList();
  }

Future<List<Map<String, dynamic>>> fetchChapters(String mangaId) async {
  try {
    final response = await http.get(Uri.parse('https://api.mangadex.org/manga/$mangaId/feed'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('Chapter data for manga $mangaId: ${json.encode(data)}');

      if (data['data'] is List) {
        var chapterData = data['data'] as List;

        return chapterData.map((chapter) {
          if (chapter['attributes'] is Map) {
            var attributes = chapter['attributes'] as Map<String, dynamic>;

            String chapterTitle = 'No title';
            if (attributes['title'] is String) {
              chapterTitle = attributes['title'];
            } else if (attributes['title'] is Map) {
              var titleMap = attributes['title'] as Map<String, dynamic>;
              chapterTitle = titleMap['en'] ?? 'No title';
            }

            String? thumbnailUrl;
            if (attributes.containsKey('thumbnail') && attributes['thumbnail'] is String) {
              thumbnailUrl = attributes['thumbnail'];
            } else if (attributes.containsKey('coverArt') && attributes['coverArt'] is String) {
              thumbnailUrl = attributes['coverArt'];
            } else if (attributes.containsKey('someOtherImageKey') && attributes['someOtherImageKey'] is String) {
              thumbnailUrl = attributes['someOtherImageKey'];
            }
            
            return {
              'id': chapter['id'],
              'chapter': attributes['chapter'] ?? 'Unknown chapter',
              'title': chapterTitle,
              'thumbnail': thumbnailUrl,
            };
          } else {
            return {
              'id': chapter['id'],
              'chapter': 'Unknown chapter',
              'title': 'No title',
            };
          }
        }).toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to fetch chapters');
    }
  } catch (e) {
    print('Error fetching chapters: $e');
    return [];
  }
}



  Future<void> fetchMangaList() async {
    final response = await http.get(Uri.parse('https://api.mangadex.org/manga'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var mangaData = data['data'] as List;
      List mangaListWithCovers = [];

      for (var manga in mangaData) {
        var coverArtId = manga['relationships']
            .firstWhere((rel) => rel['type'] == 'cover_art')['id'];

        var coverUrl = await fetchCoverUrl(coverArtId);
        var chapters = await fetchChapters(manga['id']);
        var mangaItem = {
          'id': manga['id'],
          'title': manga['attributes']['title']?['en'] ?? 'No title',
          'coverUrl': coverUrl,
          'description': manga['attributes']['description']?['en'] ?? 'No description',
          'status': manga['attributes']['status'] ?? 'Unknown',
          'year': manga['attributes']['year'] ?? 'Unknown',
          'chapters': chapters,
        };
        print('Manga item: $mangaItem');
        mangaListWithCovers.add(mangaItem);
      }

      setState(() {
        mangaList = mangaListWithCovers;
      });
    } else {
      throw Exception('Failed to load manga');
    }
  }

  Future<String> fetchCoverUrl(String coverArtId) async {
    final response = await http.get(Uri.parse('https://api.mangadex.org/cover/$coverArtId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return 'https://uploads.mangadex.org/covers/${data['data']['relationships'][0]['id']}/${data['data']['attributes']['fileName']}';
    } else {
      throw Exception('Failed to load cover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manga App'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: mangaList.length,
        itemBuilder: (context, index) {
          var manga = mangaList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaDetailPage(manga: manga),
                ),
              );
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: manga['coverUrl'] != null
                        ? Image.network(
                            manga['coverUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          )
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.image),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      manga['title'] ?? 'No title',
                      textAlign: TextAlign.center,
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
