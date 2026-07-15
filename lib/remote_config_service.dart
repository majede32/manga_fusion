import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigService {
  static const String manifestUrl = 'https://raw.githubusercontent.com/majede32/manga_fusion/main/js_sources_config.json';

  static Future<Map<String, dynamic>?> updateManifest() async {
    try {
      // تم حذف الـ headers والـ token لضمان الأمان والعمل مع المستودع العام
      final response = await http.get(Uri.parse(manifestUrl));
      
      if (response.statusCode == 200) {
        final manifest = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('manifest_data', response.body);
        print("✅ تم تحميل التحديث بنجاح");
        return manifest;
      }
    } catch (e) {
      print("خطأ في الاتصال: $e");
    }
    return null;
  }
}
