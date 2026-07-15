import 'package:http/http.dart' as http;
import 'dart:convert';

class RemoteConfigService {
  static Future<Map<String, dynamic>?> updateManifest() async {
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/majede32/manga_fusion/main/js_sources_config.json');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Full Error Details: $e");
      return null;
    }
  }
}
