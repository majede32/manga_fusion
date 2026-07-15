import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaSource {
  final String name;
  final String baseUrl;
  final Map<String, String> headers;
  final String language = "Arabic"; // التركيز على المحتوى العربي

  MangaSource({
    required this.name,
    required this.baseUrl,
    required this.headers,
  });
}

class MangaScraper {
  // قائمة المصادر العربية الموثوقة
  static final List<MangaSource> sources = [
    MangaSource(
      name: "مانجا ليك (MangaLek)",
      baseUrl: "https://mangalek.com",
      headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"},
    ),
    MangaSource(
      name: "أوليمبوس (Olympus Scans)",
      baseUrl: "https://olympustaff.com",
      headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"},
    ),
    MangaSource(
      name: "عشق (3asq)",
      baseUrl: "https://3asq.org",
      headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"},
    ),
  ];

  static MangaSource activeSource = sources[0];

  // دالة لجلب المانجا مع التزام بهوية الموقع
  static Future<String> getMangaData(String endpoint) async {
    final url = Uri.parse("${activeSource.baseUrl}$endpoint");
    final response = await http.get(url, headers: activeSource.headers);
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception("فشل جلب البيانات من ${activeSource.name}");
  }
}
