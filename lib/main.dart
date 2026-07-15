import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MangaFusionApp());
}

class MangaFusionApp extends StatelessWidget {
  const MangaFusionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Fusion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // أسود AMOLED مريح للعين (من سوات)
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amber,
        ),
      ),
      home: const MangaHomeScreen(),
    );
  }
}

// نموذج بيانات تجريبي للمانجا
class Manga {
  final String title;
  final String coverUrl;
  final String author;
  final double rating;
  final String lastChapter;
  final List<String> dummyPages;

  Manga({
    required this.title,
    required this.coverUrl,
    required this.author,
    required this.rating,
    required this.lastChapter,
    required this.dummyPages,
  });
}

// 1. الشاشة الرئيسية: تصفح المانجا (مستوحاة من خفة وأناقة سوات)
class MangaHomeScreen extends StatefulWidget {
  const MangaHomeScreen({Key? key}) : super(key: key);

  @override
  State<MangaHomeScreen> createState() => _MangaHomeScreenState();
}

class _MangaHomeScreenState extends State<MangaHomeScreen> {
  // بيانات وهمية للاختبار (استبدلها لاحقاً ببيانات الـ API أو السكرابر الخاص بك)
  final List<Manga> mangaList = [
    Manga(
      title: "One Piece",
      coverUrl: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400", // رابط صورة تجريبي سريع التحميل
      author: "Oda",
      rating: 4.9,
      lastChapter: "1110",
      dummyPages: [
        "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600",
        "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=600",
        "https://images.unsplash.com/photo-1601987177651-8edfe6c20009?w=600",
      ],
    ),
    Manga(
      title: "Solo Leveling",
      coverUrl: "https://images.unsplash.com/photo-1563089145-599997674d42?w=400",
      author: "Chugong",
      rating: 4.8,
      lastChapter: "200",
      dummyPages: [
        "https://images.unsplash.com/photo-1563089145-599997674d42?w=600",
        "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANGA FUSION',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.redAccent),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // عمودين لعرض متناسق (من سوات)
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: mangaList.length,
          itemBuilder: (context, index) {
            final manga = mangaList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaDetailScreen(manga: manga),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // الخلفية: صورة الغلاف المخزنة مؤقتاً بسلاسة
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: manga.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.redAccent),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    // تظليل السفلي لحماية وضوح النصوص
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.95)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // معلومات المانجا
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ch. ${manga.lastChapter}",
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    manga.rating.toString(),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 2. شاشة تفاصيل المانجا وقائمة الفصول
class MangaDetailScreen extends StatelessWidget {
  final Manga manga;
  const MangaDetailScreen({Key? key, required this.manga}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(manga.title), backgroundColor: const Color(0xFF161616)),
      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: manga.coverUrl,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(manga.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("الكاتب: ${manga.author}", style: const TextStyle(color: Colors.white60)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(manga.rating.toString(), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("الفصول المتاحة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // فصول تجريبية
              itemBuilder: (context, index) {
                final chapterNum = int.parse(manga.lastChapter) - index;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: const Color(0xFF1E1E1E),
                  child: ListTile(
                    title: Text("الفصل $chapterNum", style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chrome_reader_mode_outlined, color: Colors.redAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaReaderScreen(
                            mangaTitle: manga.title,
                            chapterNumber: chapterNum.toString(),
                            pages: manga.dummyPages,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// 3. قارئ الفصول الذكي: تجربة قراءة طولية متكاملة وسلسة (من مانجاميلو بلص)
class MangaReaderScreen extends StatelessWidget {
  final String mangaTitle;
  final String chapterNumber;
  final List<String> pages;

  const MangaReaderScreen({
    Key? key,
    required this.mangaTitle,
    required this.chapterNumber,
    required this.pages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء بالكامل أثناء القراءة لتركيز تام
      appBar: AppBar(
        title: Text("$mangaTitle - الفصل $chapterNumber", style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.85),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(), // تفعيل التمرير السلس والحر
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: pages[index],
            fit: BoxFit.fitWidth, // عرض الصورة بملء عرض الشاشة وملاءمتها طولياً تلقائياً
            placeholder: (context, url) => Container(
              height: 400,
              color: const Color(0xFF0F0F0F),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: const Color(0xFF1A1A1A),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.white38),
                  SizedBox(height: 8),
                  Text("فشل تحميل هذه الصفحة", style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
