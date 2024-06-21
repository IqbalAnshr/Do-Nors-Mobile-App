import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_client.dart';
import '../services/authorization_interceptor.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = fetchUserProfile();
  }

  Future<void> logout(BuildContext context) async {
    final url = '/api/auth/signout';

    final prefs = await SharedPreferences.getInstance();

    final response = await DioClient.instance
        .post(url, data: {'token': prefs.getString('accessToken')});

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }

    // Hapus token akses dari SharedPreferences
    prefs.remove('accessToken');
    prefs.remove('refreshToken');

    // Arahkan pengguna kembali ke halaman login
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false, // Hapus semua rute kecuali halaman login
    );
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final profileResponse = await DioClient.instance.get('/api/user');

      final addressResponse = await DioClient.instance.get('/api/user/address');

      if (profileResponse.statusCode == 200 &&
          addressResponse.statusCode == 200) {
        final userProfile = profileResponse.data;
        final userAddress = addressResponse.data;

        // Combine data into one map
        return {
          ...userProfile,
          ...userAddress,
        };
      } else {
        // Handle specific HTTP status codes
        if (profileResponse.statusCode == 404 ||
            addressResponse.statusCode == 404) {
          throw Exception('User profile not found');
        } else {
          throw Exception('Failed to fetch user profile');
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (DioInterceptor.authError == true) {
      DioInterceptor.authError = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      bottomNavigationBar: FluidNavBar(selectedIndex: 4),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load profile'));
          } else {
            final profileData = snapshot.data!;
            final profilePictureUrl = (profileData['user']['picture'] != null &&
                    profileData['user']['picture'].isNotEmpty &&
                    Uri.parse(profileData['user']['picture']).isAbsolute)
                ? '${dotenv.env['API_URL']}/storage/${profileData['user']['picture']}'
                : "https://plus.unsplash.com/premium_photo-1687284884918-e230d35bb15a?q=80&w=1517&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(profilePictureUrl),
                          ),
                          SizedBox(height: 20),
                          Text(
                            profileData['user']['name'] ?? 'N/A',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            (profileData['address']['city'] ?? 'N/A') +
                                ', ' +
                                (profileData['address']['province'] ?? 'N/A'),
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.edit, size: 20),
                                label: Text('Edit Profile',
                                    style: TextStyle(fontSize: 15)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.share, size: 20),
                                label: Text('Share Profile',
                                    style: TextStyle(fontSize: 15)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFFFF2156),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: [
                        ListWidget(
                            icon: Icons.person, text: 'Personal Information'),
                        ListWidget(icon: Icons.location_on, text: 'Location'),
                        ListWidget(icon: Icons.history, text: 'History'),
                        ListWidget(icon: Icons.settings, text: 'Settings'),
                        ListWidget(
                          icon: Icons.logout,
                          text: 'Logout',
                          onPressed: () => logout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ListWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  ListWidget({required this.icon, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFFFF2156), size: 35),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
