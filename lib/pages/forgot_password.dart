import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: const Color(0xFFFF2156),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: const Color(0xFFFF2156),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                // Email Field
                Container(
                  width: 350,
                  child: TextFormField(
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
                SizedBox(height: 30),
                Text(
                    'Your password reset will be send in your registered email address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 32, 32, 32),
                      fontSize: 20,
                    )),
                SizedBox(height: 30),
                // Reset Button
                ElevatedButton(
                  onPressed: () {
                    // Perform reset password action
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'RESET PASSWORD',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
