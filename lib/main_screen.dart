import 'package:flutter/material.dart';
import 'sources/manga_scraper.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<MangaModel> _mangas = [];
  List<MangaModel> _filteredMangas = [];
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
      _filteredMangas = data;
      _isLoading = false;
    });
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMangas = _mangas;
      } else {
        _filteredMangas = _mangas.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _refreshMangas,
      color: Colors.deepPurple,
      child: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
        : _filteredMangas.isEmpty 
            ? Center(child: Text("لا توجد مانجا، جرب التحديث"))
            : GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
                ),
                itemCount: _filteredMangas.length,
                itemBuilder: (context, i) {
                  final manga = _filteredMangas[i];
                  return Card(
                    color: Color(0xFF1E1E1E),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: manga.imageUrl.isNotEmpty
                              ? Image.network(manga.imageUrl, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Icon(Icons.broken_image, size: 50, color: Colors.grey))
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            manga.title, 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 1 
          ? TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ابحث عن مانجا...", 
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onChanged: _search,
              autofocus: true,
            )
          : Text("Manga Fusion", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _currentIndex == 2 
          ? Center(child: Text("الإعدادات - قريباً"))
          : _buildHome(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 1) {
              _searchController.clear();
              _search('');
            }
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "بحث"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "إعدادات"),
        ],
      ),
    );
  }
}
