import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>?;

      if (items != null) {
        return items.map((item) => Book.fromJson(item)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load books');
    }
  }
}