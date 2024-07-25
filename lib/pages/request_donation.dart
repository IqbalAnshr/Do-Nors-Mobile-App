import 'package:dio/dio.dart';
import 'package:do_nors/pages/request_detail_donation.dart';
import 'package:flutter/material.dart';
import '../components/card_donation.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import '../models/donation_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_client.dart';

class RequestDonation extends StatefulWidget {
  @override
  _RequestDonationState createState() => _RequestDonationState();
}

class _RequestDonationState extends State<RequestDonation> {
  final int _selectedIndex = 1;
  String? selectedOrganType;
  bool isLoading = true;
  List<DonationRequest> donationRequests = [];
  int currentPage = 1;
  int totalItems = 0;
  int limit = 5;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore) {
        _loadMore();
      }
    });
  }

  Future<void> fetchData() async {
    final String apiUrl =
        '${dotenv.env['API_URL']}/api/post/request?page=$currentPage&limit=$limit&search=$searchQuery&filterField=${selectedOrganType != null && selectedOrganType != 'All' ? 'organType' : ''}&filterValue=${selectedOrganType != null && selectedOrganType != 'All' ? selectedOrganType : ''}';

    setState(() {
      if (currentPage == 1) {
        isLoading = true;
      }
    });

    try {
      final response = await DioClient.instance.get(apiUrl);

      if (response.statusCode == 200) {
        final jsonData = response.data;
        List<DonationRequest> requests = [];
        for (var item in jsonData['data']) {
          DonationRequest request = DonationRequest.fromJson(item);
          requests.add(request);
        }
        setState(() {
          if (currentPage == 1) {
            donationRequests = requests;
          } else {
            donationRequests.addAll(requests);
          }
          totalItems = jsonData['totalItems'];
          isLoading = false;
          isFetchingMore = false;
        });
      } else {
        throw Exception('Failed to load donation requests');
      }
    } on DioException catch (e) {
      print('Error fetching data: $e');
      if (e.response?.statusCode == 201) {
        Future.delayed(Duration(seconds: 3), () {
          fetchData();
        });
      }
    } finally {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if ((currentPage * limit) < totalItems) {
      setState(() {
        currentPage++;
        isFetchingMore = true;
      });
      await fetchData();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 1;
    });
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/Dashboard');
        return false;
      },
      child: Scaffold(
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
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          currentPage = 1;
                        });
                        fetchData();
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedOrganType,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down),
                          style: TextStyle(color: Colors.black, fontSize: 18.0),
                          hint: Text('Filter',
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: 'Poppins')),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOrganType = newValue;
                              currentPage = 1;
                            });
                            fetchData();
                          },
                          items: <String>[
                            'All',
                            'Heart',
                            'Liver',
                            'Kidney',
                            'Intestine',
                            'Lung',
                            'Pancreas'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              alignment: Alignment.centerLeft,
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: 'Poppins'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            !isFetchingMore) {
                          _loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: donationRequests.length + 1,
                        itemBuilder: (context, index) {
                          if (index == donationRequests.length) {
                            return _buildProgressIndicator();
                          } else {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestDetailPage(
                                      requestId: donationRequests[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: DonationCard(
                                name: donationRequests[index].user.name,
                                location:
                                    '${donationRequests[index].city}, ${donationRequests[index].hospital}',
                                timeAgo: _calculateTimeAgo(
                                    donationRequests[index].createdAt),
                                organImage:
                                    'assets/images/${donationRequests[index].organType.toLowerCase()}-organ.png',
                                organName: donationRequests[index].organType,
                              ),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isFetchingMore ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
