import 'dart:convert';
import 'package:http/http.dart' as http;

// 1. الموديلات المطلوبة لواجهة التطبيق لضمان نجاح البناء
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
      title: json['title'] ?? 'بدون عنوان',
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
      title: json['title'] ?? 'فصل غير مسمى',
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
  // قائمة المصادر المعتمدة مع الترويسات الأمنية لتجاوز الحظر
  static final List<MangaSource> sources = [
    MangaSource(
      name: "مانجا ليك (MangaLek)",
      baseUrl: "https://mangalek.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
        "Referer": "https://mangalek.com/",
      },
    ),
    MangaSource(
      name: "أوليمبوس (Olympus)",
      baseUrl: "https://olympustaff.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "Referer": "https://olympustaff.com/",
      },
    ),
    MangaSource(
      name: "عشق (3asq)",
      baseUrl: "https://3asq.org",
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
        "Referer": "https://3asq.org/",
      },
    ),
  ];

  static MangaSource activeSource = sources[0];

  static void changeSource(int index) {
    if (index >= 0 && index < sources.length) {
      activeSource = sources[index];
    }
  }

  // دالة جلب قائمة المانجا عبر تحليل كود الصفحة (RegExp) لتفادي أخطاء الـ API
  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(
        Uri.parse(activeSource.baseUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<MangaModel> mangas = [];
        final htmlContent = response.body;

        // تعبير نمطي ذكي لاستخراج روابط وعناوين وصور المانجا من الهيكل الشائع للمواقع الثلاثة
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

        // إذا كان التحليل بالـ RegExp الأساسي فارغاً، نستخدم تعبيراً احتياطياً مرناً
        if (mangas.isEmpty) {
          final fallbackRegExp = RegExp(r'class="post-title".*?href="([^"]*?)">([^<]*?)<.*?src="([^"]*?)"', dotAll: true);
          for (var match in fallbackRegExp.allMatches(htmlContent)) {
            mangas.add(MangaModel(
              title: match.group(2)?.trim() ?? 'مانجا',
              mangaUrl: match.group(1) ?? '',
              imageUrl: match.group(3) ?? '',
            ));
          }
        }

        return mangas;
      } else {
        throw Exception("فشل جلب الصفحة: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchLatestManga: $e");
      return _fetchFallbackLatest();
    }
  }

  // الجلب الاحتياطي من أوليمبوس بنفس تقنية RegExp
  Future<List<MangaModel>> _fetchFallbackLatest() async {
    final fallback = sources[1];
    try {
      final response = await http.get(
        Uri.parse(fallback.baseUrl),
        headers: fallback.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<MangaModel> mangas = [];
        final regExp = RegExp(r'href="([^"]*?/manga/[^"]*?)".*?title="([^"]*?)"', dotAll: true);
        for (var match in regExp.allMatches(response.body)) {
          mangas.add(MangaModel(
            title: match.group(2)?.trim() ?? 'عنوان احتياطي',
            mangaUrl: match.group(1) ?? '',
            imageUrl: '',
          ));
        }
        return mangas;
      }
    } catch (_) {}
    return [];
  }

  // دالة جلب الفصول عبر تحليل روابط فصول الصفحة مباشرة
  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    try {
      final response = await http.get(
        Uri.parse(mangaUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<ChapterModel> chapters = [];
        // نمط لاستخراج روابط الفصول وعناوينها
        final regExp = RegExp(r'href="([^"]*?/chapter/[^"]*?)".*?>([^<]*?فصل[^<]*?)<', dotAll: true);
        
        for (var match in regExp.allMatches(response.body)) {
          final url = match.group(1) ?? '';
          final title = match.group(2)?.trim() ?? 'فصل جديد';
          if (url.isNotEmpty && !chapters.any((c) => c.chapterUrl == url)) {
            chapters.add(ChapterModel(
              title: title,
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

  // دالة جلب صور الفصل باستخدام تحليل وسوم الـ img في صفحة الفصل
  Future<List<String>> fetchChapterImages(String chapterUrl) async {
    try {
      final response = await http.get(
        Uri.parse(chapterUrl),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<String> images = [];
        // استخراج وسوم الصور التي تحوي روابط قراءة المانجا داخل الصفحة
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
