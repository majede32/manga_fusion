import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaModel {
  final String title;
  final String mangaUrl;
  final String imageUrl;

  MangaModel({
    required this.title,
    required this.mangaUrl,
    required this.imageUrl,
  });

  factory MangaModel.fromJson(Map<String, dynamic> json) {
    return MangaModel(
      title: json['title'] ?? 'No Title',
      mangaUrl: json['mangaUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ChapterModel {
  final String title;
  final String chapterUrl;

  ChapterModel({
    required this.title,
    required this.chapterUrl,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      title: json['title'] ?? 'Chapter',
      chapterUrl: json['chapterUrl'] ?? '',
    );
  }
}

class MangaSource {
  final String name;
  final String baseUrl;
  final Map<String, String> headers;

  MangaSource({
    required this.name,
    required this.baseUrl,
    required this.headers,
  });
}

class MangaScraper {
  static final List<MangaSource> sources = [
    MangaSource(
      name: "GateManga",
      baseUrl: "https://gatemanga.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "ar,en-US;q=0.9,en;q=0.8",
        "Referer": "https://gatemanga.com/",
      },
    ),
    MangaSource(
      name: "3asq",
      baseUrl: "https://3asq.org",
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
        "Accept-Language": "ar,en-US;q=0.7,en;q=0.3",
        "Referer": "https://3asq.org/",
      },
    ),
    MangaSource(
      name: "Olympus",
      baseUrl: "https://olympustaff.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "Referer": "https://olympustaff.com/",
      },
    ),
  ];

  static MangaSource activeSource = sources[0];

  static void changeSource(int index) {
    if (index >= 0 && index < sources.length) {
      activeSource = sources[index];
    }
  }

  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(
        Uri.parse(activeSource.baseUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<MangaModel> mangas = [];
        final htmlContent = response.body;

        // Optimized flexible Regex to scrape manga data safely from main page
        final regExp = RegExp(
          r'href="([^"]*?/manga/[^"]*?)".*?title="([^"]*?)".*?src="([^"]*?)"',
          dotAll: true,
        );

        final matches = regExp.allMatches(htmlContent);
        for (var match in matches) {
          final url = match.group(1) ?? '';
          final title = match.group(2) ?? '';
          final img = match.group(3) ?? '';

          if (url.isNotEmpty && !mangas.any((m) => m.mangaUrl == url)) {
            mangas.add(MangaModel(
              title: title.trim(),
              mangaUrl: url.startsWith('http') ? url : "${activeSource.baseUrl}$url",
              imageUrl: img.startsWith('http') ? img : "${activeSource.baseUrl}$img",
            ));
          }
        }

        // Secondary fallback RegExp
        if (mangas.isEmpty) {
          final fallbackRegExp = RegExp(
            r'href="([^"]*?/manga/[^"]*?)">([^<]+?)</a>', 
            dotAll: true
          );
          for (var match in fallbackRegExp.allMatches(htmlContent)) {
            final url = match.group(1) ?? '';
            final title = match.group(2)?.trim() ?? 'Manga';
            if (!mangas.any((m) => m.mangaUrl == url)) {
              mangas.add(MangaModel(
                title: title,
                mangaUrl: url.startsWith('http') ? url : "${activeSource.baseUrl}$url",
                imageUrl: '',
              ));
            }
          }
        }

        return mangas;
      } else {
        throw Exception("Server returned code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchLatestManga: $e");
      return _fetchFallbackLatest();
    }
  }

  Future<List<MangaModel>> _fetchFallbackLatest() async {
    final fallback = sources[1];
    try {
      final response = await http.get(
        Uri.parse(fallback.baseUrl),
        headers: fallback.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<MangaModel> mangas = [];
        final regExp = RegExp(r'href="([^"]*?/manga/[^"]*?)".*?>([^<]+?)</a>', dotAll: true);
        for (var match in regExp.allMatches(response.body)) {
          final url = match.group(1) ?? '';
          mangas.add(MangaModel(
            title: match.group(2)?.trim() ?? 'Manga Title',
            mangaUrl: url.startsWith('http') ? url : "${fallback.baseUrl}$url",
            imageUrl: '',
          ));
        }
        return mangas;
      }
    } catch (_) {}
    return [];
  }

  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    try {
      final response = await http.get(
        Uri.parse(mangaUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<ChapterModel> chapters = [];
        final regExp = RegExp(r'href="([^"]*?/chapter/[^"]*?)"', dotAll: true);
        
        for (var match in regExp.allMatches(response.body)) {
          final url = match.group(1) ?? '';
          if (url.isNotEmpty && !chapters.any((c) => c.chapterUrl == url)) {
            final uri = Uri.parse(url);
            final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'chapter';
            chapters.add(ChapterModel(
              title: segment.replaceAll('-', ' ').toUpperCase(),
              chapterUrl: url.startsWith('http') ? url : "${activeSource.baseUrl}$url",
            ));
          }
        }
        return chapters;
      }
    } catch (e) {
      print("Error in fetchMangaChapters: $e");
    }
    return [];
  }

  Future<List<String>> fetchChapterImages(String chapterUrl) async {
    try {
      final response = await http.get(
        Uri.parse(chapterUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<String> images = [];
        final regExp = RegExp(r'src="([^"]*?(?:uploads|images|wp-content)[^"]*?\.(?:jpg|jpeg|png|webp))"', caseSensitive: false);

        for (var match in regExp.allMatches(response.body)) {
          final imgUrl = match.group(1) ?? '';
          if (imgUrl.isNotEmpty && !images.contains(imgUrl)) {
            images.add(imgUrl.startsWith('http') ? imgUrl : "${activeSource.baseUrl}$imgUrl");
          }
        }
        return images;
      }
    } catch (e) {
      print("Error in fetchChapterImages: $e");
    }
    return [];
  }
}
