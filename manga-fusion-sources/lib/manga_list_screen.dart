import 'package:flutter/material.dart';
import 'manga_source_manager.dart';

class MangaListScreen extends StatefulWidget {
  @override
  _MangaListScreenState createState() => _MangaListScreenState();
}

class _MangaListScreenState extends State<MangaListScreen> {
  final MangaSourceManager _manager = MangaSourceManager();
  List _mangaList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    var result = await _manager.getLatestManga(1);
    
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _mangaList = result['data'];
          _errorMessage = '';
        } else {
          _errorMessage = result['error'] ?? 'حدث خطأ غير معروف';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manga Fusion")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text("خطأ: $_errorMessage"))
              : ListView.builder(
                  itemCount: _mangaList.length,
                  itemBuilder: (context, index) {
                    final manga = _mangaList[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: manga['cover'] != null 
                          ? Image.network(manga['cover'], width: 50, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported),
                        title: Text(manga['title'] ?? 'بدون عنوان'),
                        onTap: () {},
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
