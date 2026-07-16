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
    MangaSource(name: "3asq", baseUrl: "https://3asq.online", headers: {"User-Agent": "Mozilla/5.0"}),
  ];
  
  MangaSource activeSource = sources[0];

  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(Uri.parse(activeSource.baseUrl), headers: activeSource.headers);
      final List<MangaModel> mangas = [];
      final regExp = RegExp(r'href="([^"]*?/manga/[^"]+?)".*?>\s*([^<]+?)\s*<', dotAll: true);
      
      for (final match in regExp.allMatches(response.body)) {
        mangas.add(MangaModel(
          title: match.group(2)!.replaceAll('&#8211;', '-').trim(),
          mangaUrl: match.group(1)!.startsWith('http') ? match.group(1)! : activeSource.baseUrl + match.group(1)!,
          imageUrl: ""
        ));
      }
      return mangas;
    } catch (e) { return []; }
  }

  Future<List<ChapterModel>> fetchMangaChapters(String url) async => [];
  Future<List<String>> fetchChapterImages(String url) async => [];
}
