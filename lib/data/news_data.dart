import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:tabnews/data/base_url.dart';

class NewsData {
  static final _baseUrl = BaseUrl.url;
  static Future<List?> getNews(pag, order) async {
    String endpoint =
        "${_baseUrl}contents?page=$pag&per_page=30&strategy=$order";
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(endpoint),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Erro: $e");
      return null;
    }
  }

  static getContent(user, slug) async {
    String endpoint = "${_baseUrl}contents/$user/$slug";
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(endpoint),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Erro: $e");
      return null;
    }
  }

  static Future<List?> getComments(user, slug) async {
    String endpoint = "${_baseUrl}contents/$user/$slug/children";
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(endpoint),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Erro: $e");
      return null;
    }
  }
}

class StoredNewsData {
  static Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/storedNews.json");
  }

  static Future<File> saveData(storedNews) async {
    String data = json.encode(storedNews);
    final file = await getFile();
    return file.writeAsString(data);
  }

  static Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return "null";
    }
  }
}
