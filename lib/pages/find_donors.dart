import 'package:flutter/material.dart';
import '../components/card_donation.dart';
import '../components/appbar.dart';
// import '../components/navigation.dart';

class FindDonation extends StatefulWidget {
  @override
  _FindDonationState createState() => _FindDonationState();
}

class _FindDonationState extends State<FindDonation> {
  String? selectedOrganType;

  List<Map<String, dynamic>> donationRequests = [
    {
      'name': 'Amir Hamza',
      'location': 'Hertford British Hospital',
      'timeAgo': '5 Min Ago',
      'organImage': 'assets/images/kidney-organ.png',
      'organName': 'Kidney',
      'profileImage': 'assets/images/profile.jpg',
    },
    {
      'name': 'John Doe',
      'location': 'City Hospital',
      'timeAgo': '1 Hour Ago',
      'organImage': 'assets/images/heart-organ.png',
      'organName': 'Heart',
      'profileImage': 'assets/images/profile.jpg',
    },
    {
      'name': 'Emily Smith',
      'location': 'National Medical Center',
      'timeAgo': '2 Days Ago',
      'organImage': 'assets/images/liver-organ.png',
      'organName': 'Liver',
      'profileImage': 'assets/images/profile.jpg',
    },
    {
      'name': 'Sarah Johnson',
      'location': 'Hertford British Hospital',
      'timeAgo': '3 Days Ago',
      'organImage': 'assets/images/heart-organ.png',
      'organName': 'Heart',
      'profileImage': 'assets/images/profile.jpg',
    },
    {
      'name': 'Sarah Johnson',
      'location': 'Hertford British Hospital',
      'timeAgo': '3 Days Ago',
      'organImage': 'assets/images/heart-organ.png',
      'organName': 'Heart',
      'profileImage': 'assets/images/profile.jpg',
    },
    {
      'name': 'Sarah Johnson',
      'location': 'Hertford British Hospital',
      'timeAgo': '3 Days Ago',
      'organImage': 'assets/images/heart-organ.png',
      'organName': 'Heart',
      'profileImage': 'assets/images/profile.jpg',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Find Donors',
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
            child: ListView.builder(
              itemCount: donationRequests.length,
              itemBuilder: (context, index) {
                if (selectedOrganType == null ||
                    selectedOrganType == 'All' ||
                    donationRequests[index]['organName'] == selectedOrganType) {
                  return DonationCard(
                    name: donationRequests[index]['name'],
                    location: donationRequests[index]['location'],
                    timeAgo: donationRequests[index]['timeAgo'],
                    organImage: 'assets/images/kidney-organ.png',
                    organName: donationRequests[index]['organName'],
                    profileImage: donationRequests[index]['profileImage'],
                  );
                } else {
                  return SizedBox(); // Return empty widget if not matching filter
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
