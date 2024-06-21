import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/authorization_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(baseUrl: '${dotenv.env['API_URL']}'));
    dio.interceptors.add(DioInterceptor());
  }

  static Dio get instance => _instance.dio;
}
