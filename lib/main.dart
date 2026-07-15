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
      title: 'Manga Fusion',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.redAccent,
      ),
      home: const MangaHomeScreen(),
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
      appBar: AppBar(
        title: const Text(
          'MANGA FUSION',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.redAccent),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<MangaModel>>(
        future: latestMangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("فشل في تحميل المانجا، تحقق من اتصالك بالإنترنت"));
          }

          final list = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final manga = list[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailScreen(manga: manga),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GridTile(
                    footer: Container(
                      color: Colors.blackDE,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        manga.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    child: manga.imageUrl.isNotEmpty
                        ? Image.network(manga.imageUrl, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.book, size: 50))
                        : const Icon(Icons.book, size: 50),
                  ),
                ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد فصول متوفرة حالياً"));
          }

          final chapters = snapshot.data!;
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                title: Text(chapter.title),
                trailing: const Icon(Icons.play_arrow, color: Colors.redAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderScreen(chapterUrl: chapter.chapterUrl, chapterTitle: chapter.title),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ReaderScreen extends StatelessWidget {
  final String chapterUrl;
  final String chapterTitle;
  const ReaderScreen({super.key, required this.chapterUrl, required this.chapterTitle});

  @override
  Widget build(BuildContext context) {
    final scraper = MangaScraper();
    return Scaffold(
      appBar: AppBar(title: Text(chapterTitle), backgroundColor: Colors.black),
      body: FutureBuilder<List<String>>(
        future: scraper.fetchChapterImages(chapterUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("تعذر جلب صفحات هذا الفصل"));
          }

          final images = snapshot.data!;
          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.fitWidth, // العرض بملء عرض الشاشة مع الحفاظ على النسبة
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(color: Colors.grey)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 100,
                  child: Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
