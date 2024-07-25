import 'package:dio/dio.dart';
import 'package:do_nors/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart'; // Import the video_player package
import '../services/dio_client.dart'; // Import your DioClient
import '../components/appbar.dart';

class RequestDetailPage extends StatefulWidget {
  final int requestId;

  RequestDetailPage({required this.requestId});

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? requestData;
  late VideoPlayerController _videoController;

  final List<Map<String, String>> reviews = [
    {
      "name": "John Doe",
      "review": "This donation saved my life. I'm so grateful!"
    },
    {"name": "Jane Smith", "review": "Thank you for the gift of life!"},
    {
      "name": "Alex Johnson",
      "review": "The organ donation made a world of difference."
    },
    {
      "name": "Emily Brown",
      "review": "I'm so thankful to the donor and their family."
    },
    {
      "name": "Michael Davis",
      "review": "This act of kindness gave me a new lease on life."
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchRequestDetail();
    _videoController =
        VideoPlayerController.asset('assets/videos/Donor_Animated.mp4')
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
            _videoController.setLooping(true);
            _videoController.setVolume(0.0);
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> fetchRequestDetail() async {
    final String apiUrl = '/api/post/request/${widget.requestId}';

    try {
      final response = await DioClient.instance.get(apiUrl);
      if (response.statusCode == 200) {
        setState(() {
          requestData = response.data['request'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load request details');
      }
    } on DioException catch (e) {
      print('Error fetching data: $e');
      if (e.response?.statusCode == 201) {
        Future.delayed(Duration(seconds: 2), () async {
          await fetchRequestDetail();
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Request Detail'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : requestData != null
              ? SingleChildScrollView(
                  child: Container(
                    color: Colors.white, // Body background color
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_videoController.value.isInitialized)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: VideoPlayer(_videoController),
                            ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/${requestData!['organType'].toLowerCase()}-organ.png',
                                    width: 100, // Larger size
                                    height: 100, // Larger size
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    requestData!['organType'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFF2156)),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.location_city,
                                                size: 24,
                                                color: Color(0xFFFF2156)),
                                            SizedBox(width: 10),
                                            Expanded(
                                                child: Text(
                                                    '${requestData!['city']}',
                                                    style: TextStyle(
                                                        fontSize: 16))),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.local_hospital,
                                                size: 24,
                                                color: Color(0xFFFF2156)),
                                            SizedBox(width: 10),
                                            Expanded(
                                                child: Text(
                                                    '${requestData!['hospital']}',
                                                    style: TextStyle(
                                                        fontSize: 16))),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.phone,
                                                size: 24,
                                                color: Color(0xFFFF2156)),
                                            SizedBox(width: 10),
                                            Expanded(
                                                child: Text(
                                                    '${requestData!['phoneNumber']}',
                                                    style: TextStyle(
                                                        fontSize: 16))),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.note,
                                                size: 24,
                                                color: Color(0xFFFF2156)),
                                            SizedBox(width: 10),
                                            Expanded(
                                                child: Text(
                                                    '${requestData!['note']}',
                                                    style: TextStyle(
                                                        fontSize: 16))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Requester Information',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Card(
                            elevation: 5,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      (requestData!['User']
                                                      ['profilePicturePath'] !=
                                                  null &&
                                              requestData!['User']
                                                      ['profilePicturePath']
                                                  .isNotEmpty &&
                                              Uri.tryParse(
                                                          '${dotenv.env['API_URL']}/profilePictures/${requestData!['User']['profilePicturePath']}')
                                                      ?.isAbsolute ==
                                                  true)
                                          ? '${dotenv.env['API_URL']}/profilePictures/${requestData!['User']['profilePicturePath']}'
                                          : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                                      width: 80, // Larger size
                                      height: 80, // Larger size
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name: ${requestData!['User']['name']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Email: ${requestData!['User']['email']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Note: Donations must be carried out in official hospitals with proper agreements and documentation.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(child: Text('Failed to load data')),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    userId2: requestData!['User']['id'],
                    name: requestData!['User']['name'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF2156), // Button color
              minimumSize: Size(double.infinity, 50), // Full width
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              elevation: 5,
            ),
            child: Text(
              'Chat with Requester',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
