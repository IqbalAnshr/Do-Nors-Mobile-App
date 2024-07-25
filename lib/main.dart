import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'pages/create_address.dart';
import 'pages/intro_pages.dart';
import 'pages/on_boarding.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/forgot_password.dart';
import 'pages/dashboard.dart';
import 'pages/request_donation.dart';
import 'pages/search_filter.dart';
import 'pages/profile.dart';
import 'pages/find_donors.dart';
import 'pages/add_request.dart';
import 'pages/add_donor.dart';
import 'pages/update_profile_page.dart';
import 'pages/update_address.dart';
import 'pages/personal_information.dart';
import 'pages/history.dart';
import 'pages/message.dart';
import 'services/socket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  await dotenv.load();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');
  String? refreshToken = prefs.getString('refreshToken');

  final SocketService socketService = SocketService();

  String initialRoute;
  if (accessToken != null && refreshToken != null) {
    await socketService.connect();
    initialRoute = '/Dashboard';
  } else {
    initialRoute = '/';
  }

  runApp(MyApp(initialRoute: initialRoute, socketService: socketService));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final SocketService socketService;

  const MyApp(
      {Key? key, required this.initialRoute, required this.socketService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SocketService>(
          create: (_) => socketService,
        ),
      ],
      child: MaterialApp(
          title: 'Do-Nors',
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => IntroPages(),
            '/onboarding': (context) => OnboardingPage(),
            '/login': (context) => LoginPage(),
            '/register': (context) => RegisterPage(),
            '/create-address': (context) => CreateAddressPage(),
            '/forgot_password': (context) => ForgotPasswordPage(),
            '/Dashboard': (context) => Dashboard(),
            '/find_requests': (context) => RequestDonation(),
            '/Search': (context) => SearchFilterPage(),
            '/Profile': (context) => ProfilePage(),
            '/personal_information': (context) => PersonalInformationPage(),
            '/update_profile': (context) => UpdateProfilePage(),
            '/update_address': (context) => UpdateAddressPage(),
            '/history': (context) => HistoryPage(),
            '/find_donors': (context) => FindDonation(),
            '/add_request': (context) => CreateRequestPage(),
            '/add_donor': (context) => CreateDonorPage(),
            '/Messages': (context) => MessagePage(),
          }),
    );
  }
}
