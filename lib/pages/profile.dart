import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_client.dart';
import '../services/authorization_interceptor.dart';
import '../services/socket_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userProfile;
  final _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _userProfile = fetchUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> logout(BuildContext context) async {
    final String url = '/api/auth/signout';

    try {
      final prefs = await SharedPreferences.getInstance();

      // Send a signout request to the server
      final response = await DioClient.instance.post(
        url,
        data: {'token': prefs.getString('refreshToken')},
      );

      // Check if the signout request was successful
      if (response.statusCode != 200) {
        throw Exception('Failed to logout');
      }

      // Remove tokens from SharedPreferences
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      // Disconnect from the WebSocket service
      await _socketService.disconnect();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => true,
      );
    } catch (error) {
      print('Logout failed: $error');
      // Handle error, for example by showing a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/Dashboard');
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Profile'),
        bottomNavigationBar: FluidNavBar(selectedIndex: 4),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _userProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  _userProfile = fetchUserProfile();
                });
              });
              return Center(child: Center(child: CircularProgressIndicator()));
            } else {
              final profileData = snapshot.data!;
              final profilePictureUrl = (profileData['user']
                              ['profilePicturePath'] !=
                          null &&
                      profileData['user']['profilePicturePath'].isNotEmpty &&
                      Uri.tryParse(
                                  '${dotenv.env['API_URL']}/profilePictures/${profileData['user']['profilePicturePath']}')
                              ?.isAbsolute ==
                          true)
                  ? '${dotenv.env['API_URL']}/profilePictures/${profileData['user']['profilePicturePath']}'
                  : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/update_profile'),
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
                              icon: Icons.person,
                              text: 'Personal Information',
                              onPressed: () => Navigator.pushNamed(
                                  context, '/personal_information')),
                          ListWidget(
                              icon: Icons.location_on,
                              text: 'Address',
                              onPressed: () => Navigator.pushNamed(
                                  context, '/update_address')),
                          ListWidget(
                              icon: Icons.history,
                              text: 'History',
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/history')),
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
