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
    MangaSource(name: "3asq", baseUrl: "https://3asq.online", headers: {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}),
    MangaSource(name: "GateManga", baseUrl: "https://gatemanga.com", headers: {"User-Agent": "Mozilla/5.0"}),
  ];
  
  MangaSource activeSource = sources[0];

  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(Uri.parse(activeSource.baseUrl), headers: activeSource.headers);
      final List<MangaModel> mangas = [];
      
      // تعبير نمطي قوي يبحث عن أي رابط داخل الموقع يوجه للمانجا
      final linkRegex = RegExp(r'<a[^>]+href="([^"]+/(?:manga|series)/[^"]+)"[^>]*>(.*?)</a>', dotAll: true);
      
      for (final match in linkRegex.allMatches(response.body)) {
        final url = match.group(1)!;
        final innerHtml = match.group(2)!;
        
        if (url.contains('comments') || url.contains('feed')) continue;

        String title = "";
        final titleMatch = RegExp(r'title="([^"]+)"').firstMatch(match.group(0)!);
        if (titleMatch != null) {
          title = titleMatch.group(1)!;
        } else {
          title = innerHtml.replaceAll(RegExp(r'<[^>]+>'), '').trim();
        }
        
        title = title.replaceAll('&#8211;', '-').replaceAll('&#8217;', "'").replaceAll('\n', '').trim();
        if(title.isEmpty) continue;

        String img = "";
        final imgMatch = RegExp(r'(?:data-src|src)="([^"]+)"').firstMatch(innerHtml);
        if (imgMatch != null) img = imgMatch.group(1)!;
        
        if (!mangas.any((m) => m.mangaUrl == url)) {
          mangas.add(MangaModel(
            title: title,
            mangaUrl: url.startsWith('http') ? url : activeSource.baseUrl + url,
            imageUrl: img.startsWith('http') ? img : (img.isNotEmpty ? activeSource.baseUrl + img : "")
          ));
        }
      }
      
      // نظام احتياطي (Fallback): إذا لم يجد مانجا بسبب حماية الموقع، يجرب الموقع الثاني
      if (mangas.isEmpty && activeSource.name == "3asq") {
        activeSource = sources[1];
        return fetchLatestManga();
      }
      
      return mangas;
    } catch (e) {
      return [];
    }
  }

  // دوال سيتم برمجتها لاحقاً لفتح الفصول
  Future<List<ChapterModel>> fetchMangaChapters(String url) async => [];
  Future<List<String>> fetchChapterImages(String url) async => [];
}
