import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/custom_show_dialog.dart';
import '../services/socket_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final SocketService socketService = SocketService();
  bool isLoading = false;

  Future<void> registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final url = '${dotenv.env['API_URL']}/api/auth/signup';
      try {
        final response = await Dio().post(
          url,
          data: {
            'username': usernameController.text,
            'name': nameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'phoneNumber': phoneNumberController.text,
            'role': 'user',
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 201) {
          final responseData = response.data;
          final accessToken = responseData['data']['accessToken'];
          final refreshToken = responseData['data']['refreshToken'];

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('accessToken', accessToken);
          prefs.setString('refreshToken', refreshToken);

          await socketService.connect();

          // Registration successful
          showSuccessDialog(context, 'Registration Successful',
              'assets/svg/complete.svg', '/create-address');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          showErrorDialog(context, e.response?.data['errors'][0]['msg'],
              'assets/svg/error.svg');
        } else {
          showErrorDialog(context, 'An error occurred, please try again.',
              'assets/svg/error.svg');
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        if (value.length < 5) {
                          return 'Username must be at least 5 characters long';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
                          return 'Username can only contain letters, numbers, underscores, and dashes';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Name Field
                  Container(
                    width: 350,
                    child: TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline,
                            color: Color(0xFFFF2156), size: 30),
                        hintText: 'Full Name',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email Field
                  Container(
                    width: 350,
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          return 'Email is invalid';
                        }
                        return null;
                      },
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
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                          return 'Password must contain at least one number';
                        }
                        if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Confirm Password Field
                  Container(
                    width: 350,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm Password is required';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Phone Number Field
                  Container(
                    width: 350,
                    child: TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 32, 32, 32)),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone,
                            color: Color(0xFFFF2156), size: 30),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 30),
                  // Register Button
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
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
      ),
    );
  }
}
