import 'package:http/http.dart' as http;

class MangaModel {
  final String title; final String mangaUrl; final String imageUrl;
  MangaModel({required this.title, required this.mangaUrl, required this.imageUrl});
}

class ChapterModel {
  final String title; final String chapterUrl;
  ChapterModel({required this.title, required this.chapterUrl});
}

class MangaScraper {
  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(Uri.parse("https://3asq.online"), headers: {"User-Agent": "Mozilla/5.0"});
      final List<MangaModel> mangas = [];
      final regExp = RegExp(r'data-src="([^"]+?)".*?href="([^"]+?)".*?title="([^"]+?)"', dotAll: true);
      for (final match in regExp.allMatches(response.body)) {
        mangas.add(MangaModel(
          title: match.group(3)!.replaceAll('&#8211;', '-').trim(),
          mangaUrl: match.group(2)!,
          imageUrl: match.group(1)!.startsWith('http') ? match.group(1)! : "https://3asq.online" + match.group(1)!
        ));
      }
      return mangas;
    } catch (e) { return []; }
  }

  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    try {
      final response = await http.get(Uri.parse(mangaUrl), headers: {"User-Agent": "Mozilla/5.0"});
      final List<ChapterModel> chapters = [];
      final regExp = RegExp(r'href="([^"]*?/chapter/[^"]+?)"[^>]*?>\s*([^<]+?)\s*<', dotAll: true);
      for (final match in regExp.allMatches(response.body)) {
        chapters.add(ChapterModel(title: match.group(2)!.trim(), chapterUrl: match.group(1)!));
      }
      return chapters;
    } catch (e) { return []; }
  }
}
