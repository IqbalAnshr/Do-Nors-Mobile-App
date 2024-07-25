import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_show_dialog.dart';
import '../services/socket_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SocketService socketService = SocketService();

  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final url = '${dotenv.env['API_URL']}/api/auth/signIn';
    final dio = Dio();

    try {
      final response = await dio.post(
        url,
        data: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        // Login successful
        final responseData = response.data;
        final accessToken = responseData['data']['accessToken'];
        final refreshToken = responseData['data']['refreshToken'];

        // Save access token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('accessToken', accessToken);
        prefs.setString('refreshToken', refreshToken);

        await socketService.connect();

        // Navigate to dashboard on successful login
        Navigator.pushNamed(context, '/Dashboard');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response?.statusCode == 400 && e.response?.data['errors'] != null) {
        print('Dio error: ${e.response?.data['errors'][0]['msg']}');
        showErrorDialog(context, e.response?.data['errors'][0]['msg'],
            'assets/svg/error.svg');
      } else if (e.response?.statusCode == 401) {
        print('Dio error: ${e.response?.data['message']}');
        showErrorDialog(
            context, e.response?.data['message'], 'assets/svg/error.svg');
      } else if (e.response?.statusCode == 404) {
        print('Dio error: ${e.response?.data['message']}');
        showErrorDialog(
            context, e.response?.data['message'], 'assets/svg/error.svg');
      } else {
        // Other Dio errors (e.g., network issues, server errors)
        print('Dio error: ${e.message}');
        showErrorDialog(context, 'An error occurred, please try again.',
            'assets/svg/error.svg');
      }
    } catch (e) {
      // Handle other unexpected errors
      print('Login error: $e');
      showErrorDialog(context, 'An error occurred, please try again.',
          'assets/svg/error.svg');
    } finally {
      setState(() {
        isLoading =
            false; // Set isLoading to false after login process completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_red.png'),
                Text(
                  'Dare To Donate',
                  style: TextStyle(
                    color: const Color(0xFFFF2156),
                    fontSize: 28,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  'Login',
                  style: TextStyle(
                    color: const Color(0xFFFF2156),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 32, 32, 32)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined,
                          color: Color(0xFFFF2156), size: 30),
                      hintText: 'Email',
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 5),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 32, 32, 32)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outlined,
                          color: Color(0xFFFF2156), size: 30),
                      hintText: 'Password',
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 5),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                isLoading
                    ? CircularProgressIndicator() // Show loading indicator if isLoading is true
                    : ElevatedButton(
                        onPressed: isLoading ? null : () => loginUser(context),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2156),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFFFF2156),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Don’t have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF7E7E7E),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Register Now',
                        style: TextStyle(
                          color: const Color(0xFFFF2156),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/register');
                          },
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: const Color(0xFF7E7E7E),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
