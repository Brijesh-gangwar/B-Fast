
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:b_fast_user_app/models/store_model.dart';
import 'package:b_fast_user_app/secrets.dart';

class StoreService {

 //  ---singleton ---
  static final StoreService _instance = StoreService._internal();
  factory StoreService() => _instance;
  StoreService._internal();



  // get all stores
  Future<List<Stores>> getAllStores() async {
    final uri = Uri.parse('$web_baseurl/api/stores/get/all');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Stores.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stores');
    }
  }





}