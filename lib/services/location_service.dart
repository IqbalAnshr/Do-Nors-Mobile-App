import 'package:dio/dio.dart';

class LocationService {
  final String baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/api';
  final Dio dio = Dio();

  Future<List<dynamic>> fetchProvinces() async {
    final response = await dio.get('$baseUrl/provinces.json');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<dynamic>> fetchRegencies(String provinceId) async {
    final response = await dio.get('$baseUrl/regencies/$provinceId.json');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load regencies');
    }
  }

  Future<List<dynamic>> fetchDistricts(String regencyId) async {
    final response = await dio.get('$baseUrl/districts/$regencyId.json');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<dynamic>> fetchVillages(String districtId) async {
    final response = await dio.get('$baseUrl/villages/$districtId.json');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load villages');
    }
  }
}
