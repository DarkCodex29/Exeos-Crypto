import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cryptocurrency.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  
  Future<List<Cryptocurrency>> getCryptocurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=3&page=1&sparkline=false'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Cryptocurrency.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cryptocurrencies');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}