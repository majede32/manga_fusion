import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'sources/manga_scraper.dart';

class MangaDetailsPage extends StatelessWidget {
  final MangaModel manga;
  MangaDetailsPage({required this.manga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(manga.title)),
      body: Column(
        children: [
          Container(
            height: 300,
            child: CachedNetworkImage(imageUrl: manga.imageUrl, fit: BoxFit.cover),
          ),
          Expanded(
            child: FutureBuilder<List<ChapterModel>>(
              future: MangaScraper().fetchMangaChapters(manga.mangaUrl),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(snapshot.data![i].title),
                    onTap: () {
                      // هنا سيتم ربط قارئ الصور لاحقاً
                      print("فتح الفصل: ${snapshot.data![i].chapterUrl}");
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
