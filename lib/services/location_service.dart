import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final String baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/api';

  Future<List<dynamic>> fetchProvinces() async {
    final response = await http.get(Uri.parse('$baseUrl/provinces.json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<dynamic>> fetchRegencies(String provinceId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/regencies/$provinceId.json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load regencies');
    }
  }

  Future<List<dynamic>> fetchDistricts(String regencyId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/districts/$regencyId.json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<dynamic>> fetchVillages(String districtId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/villages/$districtId.json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load villages');
    }
  }
}
