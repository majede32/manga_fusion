import 'sources/manga_scraper.dart';

class MangaSourceManager {
  static final MangaSourceManager instance = MangaSourceManager._internal();
  factory MangaSourceManager() => instance;
  MangaSourceManager._internal();

  // هذه هي الدالة المفقودة التي يبحث عنها التطبيق
  Future<List<MangaModel>> getLatestManga() async {
    return await MangaScraper().fetchLatestManga();
  }
}
