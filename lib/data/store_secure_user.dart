import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreSecureUser {
  static readData(key) async {
    final storage = FlutterSecureStorage();
    String? data = await storage.read(key: key);
    return data;
  }

  static readAllData() async {
    final storage = FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
  }

  static deleteData(key) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: key);
  }

  static deleteAllData() async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  static writeData(key, value) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }
}
