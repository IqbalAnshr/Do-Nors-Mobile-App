import 'package:flutter/material.dart';

class DonationCard extends StatelessWidget {
  final String name;
  final String location;
  final String timeAgo;
  final String organImage;
  final String organName;
  final String? profileImage;

  const DonationCard({
    required this.name,
    required this.location,
    required this.timeAgo,
    required this.organImage,
    required this.organName,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (profileImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    profileImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Location: $location',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16), // Jarak antara teks dan gambar
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    organImage,
                    // Atur lebar gambar sesuai kebutuhan
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),
                  Text(
                    organName,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
