function createSource() {
  return {
    async fetchLatestManga() {
      // محاكاة لجلب المانجا من أزورا
      // في النسخة القادمة سنضيف منطق الـ DOM Parsing الكامل
      return [
        {"title": "مانجا أزورا 1", "imageUrl": "https://azorafly.com/wp-content/uploads/2026/01/cover.jpg", "mangaUrl": "https://azorafly.com/manga/manga-1"},
        {"title": "مانجا أزورا 2", "imageUrl": "https://azorafly.com/wp-content/uploads/2026/01/cover2.jpg", "mangaUrl": "https://azorafly.com/manga/manga-2"}
      ];
    },
    async fetchMangaChapters(url) {
      return [{"title": "الفصل 1", "chapterUrl": "test"}];
    },
    async fetchChapterImages(url) {
      return ["https://via.placeholder.com/500"];
    }
  };
}
