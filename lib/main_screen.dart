import 'package:flutter/material.dart';
import 'sources/manga_scraper.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<MangaModel> _mangas = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
      appBar: _currentIndex == 1 ? AppBar(title: TextField(controller: _searchController, decoration: InputDecoration(hintText: "بحث..."), onSubmitted: (val) => print("بحث عن: $val"))) : AppBar(title: Text("Manga Fusion")),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
        itemCount: _mangas.length,
        itemBuilder: (context, i) => Card(
          child: Column(children: [
            Expanded(child: _mangas[i].imageUrl.isNotEmpty ? Image.network(_mangas[i].imageUrl, fit: BoxFit.cover) : Icon(Icons.broken_image)),
            Padding(padding: EdgeInsets.all(8), child: Text(_mangas[i].title, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
