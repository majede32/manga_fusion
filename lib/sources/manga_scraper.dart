import 'package:http/http.dart' as http;

class MangaModel {
  final String title; final String mangaUrl; final String imageUrl;
  MangaModel({required this.title, required this.mangaUrl, required this.imageUrl});
}

class MangaScraper {
  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(
        Uri.parse("https://3asq.online"),
        headers: {"User-Agent": "Mozilla/5.0"}
      );
      final List<MangaModel> mangas = [];
      
      // RegExp مُحدث يلتقط: الرابط، العنوان، ورابط الصورة
      final regExp = RegExp(r'data-src="([^"]+?)".*?href="([^"]+?)".*?title="([^"]+?)"', dotAll: true);
      
      for (final match in regExp.allMatches(response.body)) {
        mangas.add(MangaModel(
          imageUrl: match.group(1)!,
          mangaUrl: match.group(2)!,
          title: match.group(3)!.trim(),
        ));
      }
      return mangas;
    } catch (e) {
      return [];
    }
  }
}
