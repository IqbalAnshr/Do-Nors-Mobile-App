import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/carousel_image.dart';
import '../components/card_donation.dart';
import '../components/drawer.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import '../models/donation_request.dart';
import '../services/dio_client.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      final response = await DioClient.instance.get(apiUrl!);
      if (response.statusCode == 200) {
        final jsonData = response.data;
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: HomeAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      bottomNavigationBar: FluidNavBar(
        selectedIndex: _selectedIndex,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CarouselWithIndicator(),
                      SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics:
                            NeverScrollableScrollPhysics(), // untuk menghindari scrolling GridView
                        children: List.generate(
                          6,
                          (index) {
                            IconData iconData;
                            String categoryName;

                            // Tentukan ikon dan nama kategori berdasarkan indeks
                            switch (index) {
                              case 0:
                                iconData = Icons.person_search_outlined;
                                categoryName = 'Find Donors';
                                break;
                              case 1:
                                iconData = Icons.ads_click_outlined;
                                categoryName = 'Find Faster';
                                break;
                              case 2:
                                iconData = Icons.volunteer_activism_outlined;
                                categoryName = 'Support Us';
                                break;
                              case 3:
                                iconData = Icons.headset_mic_rounded;
                                categoryName = 'Assistant';
                                break;
                              case 4:
                                iconData = Icons.report;
                                categoryName = 'Report';
                                break;
                              case 5:
                                iconData = Icons.campaign_sharp;
                                categoryName = 'Campaigns';
                                break;
                              default:
                                iconData = Icons
                                    .category; // Default icon jika tidak ada yang cocok
                                categoryName = 'Category';
                                break;
                            }

                            return GestureDetector(
                              onTap: () {
                                // Aksi ketika ikon diklik
                                switch (index) {
                                  case 0:
                                    Navigator.pushNamed(
                                        context, '/find_donors');
                                }
                              },
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      iconData,
                                      color: Color(0xFFFF2156),
                                      size: 35,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Donation Request',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 20),

                      // List of donation requests here
                      ListView.builder(
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
                    ],
                  ),
                ),
              ),
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
