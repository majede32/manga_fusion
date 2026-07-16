import 'package:flutter/material.dart';
import 'sources/manga_scraper.dart';

void main() {
  runApp(const MangaFusionApp());
}

class MangaFusionApp extends StatelessWidget {
  const MangaFusionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
      home: MainScreen(),
    );
  }
}

class MangaHomeScreen extends StatefulWidget {
  const MangaHomeScreen({super.key});
  @override
  State<MangaHomeScreen> createState() => _MangaHomeScreenState();
}

class _MangaHomeScreenState extends State<MangaHomeScreen> {
  final MangaScraper scraper = MangaScraper();
  late Future<List<MangaModel>> latestMangaFuture;

  @override
  void initState() {
    super.initState();
    latestMangaFuture = scraper.fetchLatestManga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MANGA FUSION'), backgroundColor: Colors.black),
      body: FutureBuilder<List<MangaModel>>(
        future: latestMangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error.toString()}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد مانجا متاحة حالياً"));
          }
          final list = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final manga = list[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MangaDetailScreen(manga: manga))),
                child: Card(child: Column(children: [Expanded(child: Image.network(manga.imageUrl, fit: BoxFit.cover, errorBuilder: (c,o,s) => const Icon(Icons.broken_image))), Text(manga.title, maxLines: 1)]))
              );
            },
          );
        },
      ),
    );
  }
}

class MangaDetailScreen extends StatelessWidget {
  final MangaModel manga;
  const MangaDetailScreen({super.key, required this.manga});
  @override
  Widget build(BuildContext context) {
    final scraper = MangaScraper();
    return Scaffold(
      appBar: AppBar(title: Text(manga.title), backgroundColor: Colors.black),
      body: FutureBuilder<List<ChapterModel>>(
        future: scraper.fetchMangaChapters(manga.mangaUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("خطأ: ${snapshot.error.toString()}"));
          final chapters = snapshot.data ?? [];
          return ListView.builder(itemCount: chapters.length, itemBuilder: (c, i) => ListTile(title: Text(chapters[i].title), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ReaderScreen(chapterUrl: chapters[i].chapterUrl, chapterTitle: chapters[i].title)))));
        },
      ),
    );
  }
}

class ReaderScreen extends StatelessWidget {
  final String chapterUrl, chapterTitle;
  const ReaderScreen({super.key, required this.chapterUrl, required this.chapterTitle});
  @override
  Widget build(BuildContext context) {
    final scraper = MangaScraper();
    return Scaffold(
      appBar: AppBar(title: Text(chapterTitle), backgroundColor: Colors.black),
      body: FutureBuilder<List<String>>(
        future: scraper.fetchChapterImages(chapterUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("خطأ: ${snapshot.error.toString()}"));
          final images = snapshot.data ?? [];
          return ListView.builder(itemCount: images.length, itemBuilder: (c, i) => Image.network(images[i]));
        },
      ),
    );
  }
}
