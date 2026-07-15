import 'dart:convert';
import 'package:http/http.dart' as http;

// 1. تعريف موديل المانجا المطلوبة في واجهة التطبيق
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
      title: json['title'] ?? json['name'] ?? 'بدون عنوان',
      mangaUrl: json['mangaUrl'] ?? json['link'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['cover'] ?? '',
    );
  }
}

// 2. تعريف موديل الفصول المطلوبة في واجهة التطبيق
class ChapterModel {
  final String title;
  final String chapterUrl;

  ChapterModel({
    required this.title,
    required this.chapterUrl,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      title: json['title'] ?? json['name'] ?? 'فصل غير مسمى',
      chapterUrl: json['chapterUrl'] ?? json['link'] ?? '',
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
  // المصادر العربية المتاحة
  static final List<MangaSource> sources = [
    MangaSource(
      name: "مانجا ليك (MangaLek)",
      baseUrl: "https://mangalek.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
        "Referer": "https://mangalek.com/",
        "Accept": "application/json, text/plain, */*",
      },
    ),
    MangaSource(
      name: "أوليمبوس (Olympus)",
      baseUrl: "https://olympustaff.com",
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
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

  // 3. جلب أحدث المانجا المترجمة (تطابق متطلبات main.dart)
  Future<List<MangaModel>> fetchLatestManga() async {
    try {
      final response = await http.get(
        Uri.parse("${activeSource.baseUrl}/api/manga/updates?page=1"),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MangaModel.fromJson(json)).toList();
      } else {
        throw Exception("فشل الاتصال بـ ${activeSource.name}");
      }
    } catch (e) {
      print("Error in fetchLatestManga: $e");
      // Fallback في حال تعطل المصدر الأساسي، نجلب من أوليمبوس تلقائياً
      return _fetchFallbackLatest();
    }
  }

  // دالة جلب احتياطية لتفادي انقطاع الاتصال
  Future<List<MangaModel>> _fetchFallbackLatest() async {
    final fallback = sources[1];
    try {
      final response = await http.get(
        Uri.parse("${fallback.baseUrl}/api/manga/updates?page=1"),
        headers: fallback.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MangaModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return []; // مصفوفة فارغة لتجنب تحطم التطبيق
  }

  // 4. جلب فصول المانجا المحددة (تطابق متطلبات main.dart)
  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    try {
      // إرسال الطلب لروابط الفصول مع تمرير رابط المانجا كمعامل أو مسار
      final encodedUrl = Uri.encodeComponent(mangaUrl);
      final response = await http.get(
        Uri.parse("${activeSource.baseUrl}/api/manga/chapters?url=$encodedUrl"),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChapterModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error in fetchMangaChapters: $e");
    }
    return [];
  }

  // 5. جلب صور الفصل للقراءة (تطابق متطلبات main.dart)
  Future<List<String>> fetchChapterImages(String chapterUrl) async {
    try {
      final encodedUrl = Uri.encodeComponent(chapterUrl);
      final response = await http.get(
        Uri.parse("${activeSource.baseUrl}/api/chapter/images?url=$encodedUrl"),
        headers: activeSource.headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      }
    } catch (e) {
      print("Error in fetchChapterImages: $e");
    }
    return [];
  }
}
