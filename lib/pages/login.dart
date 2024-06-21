import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dio_client.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    try {
      final url = '${dotenv.env['API_URL']}/api/auth/signIn';
      final response = await DioClient.instance.post(
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

        // Navigate to dashboard on successful login
        Navigator.pushNamed(context, '/Dashboard');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data['errors'] != null) {
        // Registration failed
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Registration Failed'),
            content: Text('${e.response?.data['errors'][0]['msg']}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else if (e.response?.statusCode == 500 &&
          e.response?.data['errors'] != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Wrong email or password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('Dio error: ${e.message}');
        if (e.response != null) {
          print('Response data: ${e.response!.data}');
        }
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to connect to server.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed checkTokenAndNavigate(context); from build method

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
                // Email Field
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
                // Password Field
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
                // Login Button
                ElevatedButton(
                  onPressed: () => loginUser(context),
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
                // Forgot Password
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
                // Register Text
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

                      // Register Button text
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
