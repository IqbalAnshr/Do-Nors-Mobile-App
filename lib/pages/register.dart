import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    final url = '${dotenv.env['API_URL']}/api/auth/signup';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'username': usernameController.text,
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'phoneNumber': phoneNumberController.text,
        'role': 'user', // Role default sebagai user
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['data']['accessToken'];
      final refreshToken = responseData['data']['refreshToken'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', accessToken);
      prefs.setString('refreshToken', refreshToken);

      // Registration successful
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('Your account has been created successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushNamed(context, '/create-address');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else if (response.statusCode == 400) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text('${json.decode(response.body)['errors'][0]['msg']}'),
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
      // Registration failed
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text('${json.decode(response.body)['message']}'),
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
                  'Register',
                  style: TextStyle(
                    color: const Color(0xFFFF2156),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
                SizedBox(height: 20),
                // Username Field
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 32, 32, 32)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person,
                          color: Color(0xFFFF2156), size: 30),
                      hintText: 'Username',
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
                // Name Field
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 32, 32, 32)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline,
                          color: Color(0xFFFF2156), size: 30),
                      hintText: 'Name',
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
                SizedBox(height: 20),
                // Confirm Password Field
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
                      hintText: 'Confirm Password',
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
                // Phone Number Field
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 32, 32, 32)),
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.phone, color: Color(0xFFFF2156), size: 30),
                      hintText: 'Phone Number',
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
                // Register Button
                ElevatedButton(
                  onPressed: () => registerUser(context),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'REGISTER',
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
                SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF7E7E7E),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Login Button text
                      TextSpan(
                        text: 'Login Now',
                        style: TextStyle(
                          color: const Color(0xFFFF2156),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
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
