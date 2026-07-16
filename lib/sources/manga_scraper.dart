import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaModel {
  final String title; final String mangaUrl; final String imageUrl;
  MangaModel({required this.title, required this.mangaUrl, required this.imageUrl});
}

class ChapterModel {
  final String title; final String chapterUrl;
  ChapterModel({required this.title, required this.chapterUrl});
}

class MangaSource {
  final String name; final String baseUrl; final Map<String, String> headers;
  MangaSource({required this.name, required this.baseUrl, required this.headers});
}

class MangaScraper {
  static final List<MangaSource> sources = [
    MangaSource(name: "3asq", baseUrl: "https://3asq.org", headers: {"User-Agent": "Mozilla/5.0"}),
  ];
  static MangaSource activeSource = sources[0];

  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(Uri.parse(activeSource.baseUrl), headers: activeSource.headers);
      final List<MangaModel> mangas = [];
      // البحث عن أي رابط يحتوي على /manga/ مع العنوان
      final regExp = RegExp(r'href="([^"]*?/manga/[^"]+?)".*?>\s*([^<]+?)\s*<', dotAll: true);
      final matches = regExp.allMatches(response.body);
      for (var match in matches) {
        mangas.add(MangaModel(
          title: match.group(2)!.trim(),
          mangaUrl: match.group(1)!.startsWith('http') ? match.group(1)! : "${activeSource.baseUrl}${match.group(1)}",
          imageUrl: "" // سنقوم بتطويرها لاحقاً
        ));
      }
      return mangas;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    final response = await http.get(Uri.parse(mangaUrl), headers: activeSource.headers);
    final List<ChapterModel> chapters = [];
    final regExp = RegExp(r'href="([^"]*?/chapter/[^"]+?)"[^>]*?>\s*([^<]+?)\s*<', dotAll: true);
    for (var match in regExp.allMatches(response.body)) {
      chapters.add(ChapterModel(title: match.group(2)!.trim(), chapterUrl: match.group(1)!));
    }
    return chapters;
  }

  Future<List<String>> fetchChapterImages(String chapterUrl) async {
    final response = await http.get(Uri.parse(chapterUrl), headers: activeSource.headers);
    final regExp = RegExp(r'src="(https?://[^"]+?\.(?:jpg|png|webp))"');
    return regExp.allMatches(response.body).map((m) => m.group(1)!).toList();
  }
}
