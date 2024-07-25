import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioInterceptor extends Interceptor {
  static bool authError = false;

  // DioInterceptor()
  //     : dio = Dio(BaseOptions(
  //         baseUrl: '${dotenv.env['BASE_URL']}',
  //         connectTimeout: Duration(milliseconds: 5000),
  //         receiveTimeout: Duration(milliseconds: 3000),
  //       ));

  Dio dio = Dio(
    BaseOptions(
      baseUrl: '${dotenv.env['API_URL']} ?? http://147.139.169.78',
    ),
  );

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (token != null) {
      options.headers.addAll({
        "x-access-token": "Bearer $token",
      });
    }

    if (refreshToken == null) {
      authError = true;
      return super.onRequest(options, handler);
    }

    // Log request details for debugging
    print("--> ${options.method} ${options.baseUrl}${options.path}");
    print("Headers: ${options.headers}");
    print("Body: ${options.data}");

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details for debugging
    print(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}");
    print("Headers: ${response.headers}");
    print("Response: ${response.data}");

    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final response = await refreshToken();
      if (response?.statusCode == 200) {
        try {
          handler.resolve(await _retry(err.requestOptions));
        } on DioException catch (e) {
          handler.next(e);
        }
        return;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
      }
    } else if (err.type == DioExceptionType.connectionError) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
    }

    handler.next(err);
  }

  Future<Response?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    print("Refresh Token: $refreshToken");

    if (refreshToken == null) {
      return null;
    }

    try {
      final response =
          await dio.post('${dotenv.env['API_URL']}/api/auth/refresh-token',
              options: Options(
                headers: {
                  "Content-Type": "application/x-www-form-urlencoded",
                },
              ),
              data: {
            'token': refreshToken,
          });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        await prefs.setString('accessToken', newAccessToken);
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return null;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final options = Options(
      method: requestOptions.method,
      headers: {
        "x-access-token": "Bearer $token",
      },
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
