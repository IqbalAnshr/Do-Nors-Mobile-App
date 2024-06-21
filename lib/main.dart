import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/create_address.dart';
import 'pages/intro_pages.dart';
import 'pages/on_boarding.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/forgot_password.dart';
// import 'pages/home_page.dart';
import 'pages/dashboard.dart';
import 'pages/request_donation.dart';
import 'pages/search_filter.dart';
import 'pages/profile.dart';
import 'pages/find_donors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  runApp(MyApp(initialRoute: accessToken != null ? '/Dashboard' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Do-Nors',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => IntroPages(),
          '/onboarding': (context) => OnboardingPage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/create-address': (context) => CreateAddressPage(),
          '/forgot_password': (context) => ForgotPasswordPage(),
          // '/home': (context) => HomePage(),
          '/Dashboard': (context) => Dashboard(),
          '/Explore': (
            context,
          ) =>
              RequestDonation(),
          '/Search': (context) => SearchFilterPage(),
          '/Profile': (context) => ProfilePage(),
          '/find_donors': (context) => FindDonation(),
        });
  }
}
