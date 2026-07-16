import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'sources/manga_scraper.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<MangaModel> _mangas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshMangas();
  }

  Future<void> _refreshMangas() async {
    setState(() => _isLoading = true);
    final data = await MangaScraper().fetchLatestManga();
    setState(() {
      _mangas = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manga Fusion")),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _mangas.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => print("تم الضغط على: ${_mangas[i].title}"), // هنا سيتم فتح صفحة الفصول لاحقاً
          child: Column(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _mangas[i].imageUrl,
                httpHeaders: {"Referer": "https://3asq.online/"},
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: Colors.grey[800]),
                errorWidget: (c, u, e) => Icon(Icons.broken_image),
              ),
            )),
            Padding(padding: EdgeInsets.only(top: 5), child: Text(_mangas[i].title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "بحث"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "إعدادات"),
        ],
      ),
    );
  }
}
