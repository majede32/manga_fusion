import 'package:http/http.dart' as http;

class MangaModel {
  final String title; final String mangaUrl; final String imageUrl;
  MangaModel({required this.title, required this.mangaUrl, required this.imageUrl});
}

class MangaScraper {
  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      // نستخدم Headers كاملة لمحاكاة متصفح حقيقي وتجنب الحماية
      final response = await http.get(
        Uri.parse("https://3asq.online"),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
          "Referer": "https://3asq.online/"
        }
      );

      final List<MangaModel> mangas = [];
      
      // هذا الـ RegExp يبحث عن روابط المانجا داخل القوائم
      final regExp = RegExp(r'href="([^"]*?/manga/[^"]+?)".*?title="([^"]+?)"', dotAll: true);
      
      for (final match in regExp.allMatches(response.body)) {
        mangas.add(MangaModel(
          title: match.group(2)!.trim(),
          mangaUrl: match.group(1)!,
          imageUrl: "" // سنقوم بتعديلها لاحقاً
        ));
      }
      return mangas;
    } catch (e) {
      return [];
    }
  }
}
