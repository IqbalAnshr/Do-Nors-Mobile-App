import 'package:flutter/material.dart';

class IntroPages extends StatelessWidget {
  const IntroPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Membuat lebar container menjadi penuh
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 33, 86),
          image: DecorationImage(
            image: AssetImage('assets/images/Splash_screen.png'),
            fit: BoxFit
                .cover, // Mengatur agar gambar mengisi container dengan baik
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/logo.png'),
                    SizedBox(height: 20),
                    Text(
                      'Peoples Lives Matter',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Aplikasi yang membantu anda dalam mencari pendonor organ dalam sekitar anda',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/onboarding');
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Center(
                        child: Text('Mulai',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
