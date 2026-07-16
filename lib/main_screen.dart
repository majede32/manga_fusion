import 'package:flutter/material.dart';
import 'sources/manga_scraper.dart'; // استيراد السكرايبر

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
    final scraper = MangaScraper();
    final data = await scraper.fetchLatestManga();
    setState(() {
      _mangas = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المانجا المحدثة")),
      body: _currentIndex == 0 
        ? RefreshIndicator(
            onRefresh: _refreshMangas,
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _mangas.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(_mangas[i].title),
                    leading: _mangas[i].imageUrl.isNotEmpty ? Image.network(_mangas[i].imageUrl, width: 50) : Icon(Icons.book),
                  ),
                ),
          )
        : Center(child: Text("قريباً: البحث والإعدادات")),
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
