import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class MangaModel {
  final String title;
  final String imageUrl;
  final String mangaUrl;

  MangaModel({required this.title, required this.imageUrl, required this.mangaUrl});
}

class ChapterModel {
  final String title;
  final String chapterUrl;

  ChapterModel({required this.title, required this.chapterUrl});
}

class MangaScraper {
  // موقع مصدر مانجا تجريبي نشط (يمكن تغييره للمصدر المطلوب لاحقاً)
  final String baseUrl = "https://mangalek.com"; 

  // 1. جلب قائمة المانجا الأحدث من الصفحة الرئيسية
  Future<List<MangaModel>> fetchLatestManga() async {
    List<MangaModel> mangaList = [];
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      });
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        // استهداف الكروت الخاصة بالمانجا في هيكل HTML للموقع
        var cards = document.querySelectorAll('.manga-card, .manga-item, .entry'); 
        for (var card in cards) {
          var titleElement = card.querySelector('.title, h3, .manga-name a');
          var imgElement = card.querySelector('img');
          var linkElement = card.querySelector('a');

          if (titleElement != null && linkElement != null) {
            mangaList.add(MangaModel(
              title: titleElement.text.trim(),
              imageUrl: imgElement?.attributes['src'] ?? imgElement?.attributes['data-src'] ?? '',
              mangaUrl: linkElement.attributes['href'] ?? '',
            ));
          }
        }
      }
    } catch (e) {
      print("Error fetching latest manga: $e");
    }
    return mangaList;
  }

  // 2. جلب قائمة فصول مانجا معينة عند الضغط عليها
  Future<List<ChapterModel>> fetchMangaChapters(String mangaUrl) async {
    List<ChapterModel> chapters = [];
    try {
      final response = await http.get(Uri.parse(mangaUrl), headers: {
        'User-Agent': 'Mozilla/5.0'
      });
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var elements = document.querySelectorAll('.chapter-item, .chapters-list a, .wp-manga-chapter a');
        for (var element in elements) {
          var title = element.text.trim();
          var url = element.attributes['href'] ?? '';
          if (url.isNotEmpty) {
            chapters.add(ChapterModel(title: title, chapterUrl: url));
          }
        }
      }
    } catch (e) {
      print("Error fetching chapters: $e");
    }
    return chapters;
  }

  // 3. جلب صفحات الصور الخاصة بالفصل لقراءتها
  Future<List<String>> fetchChapterImages(String chapterUrl) async {
    List<String> images = [];
    try {
      final response = await http.get(Uri.parse(chapterUrl), headers: {
        'User-Agent': 'Mozilla/5.0'
      });
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var imgElements = document.querySelectorAll('.page-break img, .reading-content img, .vung-doc img');
        for (var img in imgElements) {
          var src = img.attributes['src'] ?? img.attributes['data-src'] ?? img.attributes['data-lazy-src'] ?? '';
          if (src.isNotEmpty) {
            images.add(src.trim());
          }
        }
      }
    } catch (e) {
      print("Error fetching images: $e");
    }
    return images;
  }
}
