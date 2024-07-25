import 'package:flutter/material.dart';
import '../services/dio_client.dart';
import '../components/appbar.dart';

class PersonalInformationPage extends StatefulWidget {
  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final profileResponse = await DioClient.instance.get('/api/user');
      final addressResponse = await DioClient.instance.get('/api/user/address');

      if (profileResponse.statusCode == 200 &&
          addressResponse.statusCode == 200) {
        final userProfile = profileResponse.data['user'];
        final userAddress = addressResponse.data['address'];

        setState(() {
          profileData = {
            ...userProfile,
            ...userAddress,
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        isLoading = false;
      });
      showErrorDialog();
    }
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load profile data. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Personal Information"),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
              ? Center(child: Text('No Profile Data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildProfileDetail(
                          Icons.person, 'Username', profileData!['username']),
                      Divider(),
                      buildProfileDetail(
                          Icons.email, 'Email', profileData!['email']),
                      Divider(),
                      buildProfileDetail(Icons.phone, 'Phone Number',
                          profileData!['phoneNumber']),
                      Divider(),
                      buildProfileDetail(
                          Icons.home, 'Address', formatAddress(profileData!)),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget buildProfileDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Color(0xFFFF2156)),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatAddress(Map<String, dynamic> data) {
    return '${data['streetName']}, ${data['subdistrict']}, ${data['district']}, ${data['city']}, ${data['province']}, ${data['postalCode']}';
  }
}
