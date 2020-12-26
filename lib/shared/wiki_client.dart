import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/entry.dart';

abstract class Restful {
  static Future<Entry> getEntry(String title) async {
    final url = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/${title}";
    return new Entry(json.decode(await http.read(url)));
  }
}
