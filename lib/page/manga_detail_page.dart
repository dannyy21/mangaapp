import 'package:flutter/material.dart';
import 'package:mangaapp/page/chapter_detail_page.dart';

class MangaDetailPage extends StatefulWidget {
  final Map<String, dynamic> manga;

  const MangaDetailPage({super.key, required this.manga});

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.manga['chapters']);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga['title'] ?? 'Detail Manga'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.manga['coverUrl'] != null)
              Image.network(
                widget.manga['coverUrl'],
                fit: BoxFit.cover,
                height: 200,
              ),
            SizedBox(height: 16.0),
            Text(
              widget.manga['title'] ?? 'No title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.manga['description'] ?? "No description",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Other details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Status: ${widget.manga['status'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Published: ${widget.manga['year'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Chapters:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            buildChapterList(widget.manga['chapters']),
          ],
        ),
      ),
    );
  }

  Widget buildChapterList(List<dynamic>? chapters) {
  if (chapters == null || chapters.isEmpty) {
    return Text('No chapters available');
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: chapters.length,
    itemBuilder: (context, index) {
      var chapter = chapters[index];
      var thumbnailUrl = chapter['thumbnail'] ?? widget.manga['coverUrl'];

      return ListTile(
        leading: thumbnailUrl != null
            ? Image.network(
                thumbnailUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                },
              )
            : Icon(Icons.image),
        title: Text('Chapter ${chapter['chapter']}'),
        subtitle: Text(chapter['title']?.isNotEmpty == true ? chapter['title'] : 'No title'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterDetailPage(chapter: chapter),
            ),
          );
        },
      );
    },
  );
}
}
