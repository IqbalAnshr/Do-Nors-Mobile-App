// components/donation_details_modal.dart
import 'package:do_nors/pages/chat.dart';
import 'package:flutter/material.dart';

void showDonationDetails(
    BuildContext context, Map<String, dynamic> donationRequest) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -55, // Adjust the position as needed
                left: MediaQuery.of(context).size.width / 2 -
                    60, // Center the avatar
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: 5),
                    image: DecorationImage(
                      image: NetworkImage(donationRequest['profileImage']),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(
                        8.0), // Adjust border radius if needed
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 70,
                    left: 16,
                    right: 16), // Adjust top padding to fit avatar
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        donationRequest['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        donationRequest['location'],
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.local_hospital,
                                  color: Color(0xFFFF2156)),
                              SizedBox(height: 8),
                              Text('Organ Type'),
                              Text(donationRequest['organName'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue),
                              SizedBox(height: 8),
                              Text('Time Ago'),
                              Text(
                                  _calculateTimeAgo(donationRequest['timeAgo']),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    userId2: donationRequest['userId'],
                                    name: donationRequest['name'],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.chat,
                                color: Colors
                                    .white), // Ubah warna ikon menjadi putih
                            label: Text(
                              'Text Now',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Ubah warna teks menjadi putih
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 121, 165, 123),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Ubah border radius di sini
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    userId2: donationRequest['userId'],
                                    name: donationRequest['name'],
                                    chat: _createDonationRequestMessage(
                                        donationRequest['name']),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.send,
                                color: Colors
                                    .white), // Ubah warna ikon menjadi putih
                            label: Text(
                              'Request',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Ubah warna teks menjadi putih
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF2156),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Ubah border radius di sini
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              donationRequest['note'],
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String _createDonationRequestMessage(String name) {
  return '''
Halo $name,

Kami harap Anda dalam keadaan sehat. Kami ingin menyampaikan permohonan Anda untuk mendonorkan organ. Dukungan Anda sangat berarti dan dapat memberikan harapan baru bagi mereka yang membutuhkan.

Jika Anda bersedia membantu, mohon informasikan kepada kami kapan dan di mana Anda dapat melakukannya. Kami siap memberikan informasi lebih lanjut dan menjawab pertanyaan Anda.

Terima kasih banyak atas perhatian dan dukungan Anda.
''';
}

String _calculateTimeAgo(String createdAt) {
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
