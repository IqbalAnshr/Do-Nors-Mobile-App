import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/card_donation.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import '../models/donation_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RequestDonation extends StatefulWidget {
  @override
  _RequestDonationState createState() => _RequestDonationState();
}

class _RequestDonationState extends State<RequestDonation> {
  final int _selectedIndex = 3;
  String? selectedOrganType;
  bool isLoading = true;
  List<DonationRequest> donationRequests = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String? apiUrl = '${dotenv.env['API_URL']}/api/post/request';
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl!));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<DonationRequest> requests = [];
        for (var item in jsonData['data']) {
          DonationRequest request = DonationRequest.fromJson(item);
          requests.add(request);
        }
        setState(() {
          donationRequests = requests;
        });
      } else {
        throw Exception('Failed to load donation requests');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Donation Request',
      ),
      bottomNavigationBar: FluidNavBar(
        selectedIndex: _selectedIndex,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Colors.white),
            child: DropdownButton<String>(
              value: selectedOrganType,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              style: TextStyle(color: Colors.black, fontSize: 18.0),
              hint: Text('Filter by Organ Type',
                  style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins')),
              padding: EdgeInsets.symmetric(horizontal: 15),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOrganType = newValue;
                });
              },
              items: <String>[
                'All',
                'Heart',
                'Liver',
                'Kidney',
                'Brain',
                'Lungs'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.centerLeft,
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchData,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: donationRequests.length,
                        itemBuilder: (context, index) {
                          return DonationCard(
                            name: donationRequests[index].user.name,
                            location: donationRequests[index].hospital,
                            timeAgo: _calculateTimeAgo(
                                donationRequests[index].createdAt),
                            organImage:
                                'assets/images/kidney-organ.png', // Gambar organ sementara
                            organName: donationRequests[index].organType,
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _calculateTimeAgo(String createdAt) {
    // Contoh sederhana untuk menghitung waktu yang lalu
    // Anda dapat menggunakan pustaka date formatting untuk yang lebih lengkap
    DateTime createdAtDateTime = DateTime.parse(createdAt);
    Duration difference = DateTime.now().difference(createdAtDateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
