import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_client.dart';
import '../components/card_donation.dart';
import '../components/appbar.dart';
import '../components/donation_details_modal.dart';

class FindDonation extends StatefulWidget {
  @override
  _FindDonationState createState() => _FindDonationState();
}

class _FindDonationState extends State<FindDonation> {
  String? selectedOrganType;
  List<Map<String, dynamic>> donationRequests = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  int currentPage = 1;
  int totalItems = 0;
  int limit = 10;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDonationRequests();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchDonationRequests() async {
    if (currentPage == 1) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isFetchingMore = true;
      });
    }

    try {
      final response =
          await DioClient.instance.get('/api/post/donor', queryParameters: {
        'page': currentPage,
        'limit': limit,
        'search': searchQuery,
        'sort': 'desc',
        'filterField': selectedOrganType != null && selectedOrganType != 'All'
            ? 'organType'
            : '',
        'filterValue': selectedOrganType != null && selectedOrganType != 'All'
            ? selectedOrganType
            : '',
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        setState(() {
          if (currentPage == 1) {
            donationRequests = data.map((item) {
              return {
                'userId': item['User']?['id'] ?? 'Unknown ID',
                'name': item['User']?['name'] ?? 'Unknown Name',
                'location': item['User']?['Address'] != null
                    ? '${item['User']['Address']['city']}, ${item['User']['Address']['district']}'
                    : 'Unknown Location',
                'timeAgo': item['createdAt'],
                'organImage':
                    'assets/images/${item['organType'].toLowerCase()}-organ.png',
                'organName': item['organType'],
                'profileImage': (item['User']?['profilePicturePath'] != null &&
                        item['User']['profilePicturePath'].isNotEmpty &&
                        Uri.tryParse(
                                    '${dotenv.env['API_URL']}/profilePictures/${item['User']['profilePicturePath']}')
                                ?.isAbsolute ==
                            true)
                    ? '${dotenv.env['API_URL']}/profilePictures/${item['User']['profilePicturePath']}'
                    : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                'note': item['note'],
              };
            }).toList();
          } else {
            donationRequests.addAll(data.map((item) {
              return {
                'name': item['User']?['name'] ?? 'Unknown Name',
                'location': item['User']?['Address'] != null
                    ? '${item['User']['Address']['city']}, ${item['User']['Address']['district']}'
                    : 'Unknown Location',
                'timeAgo': item['createdAt'],
                'organImage':
                    'assets/images/${item['organType'].toLowerCase()}-organ.png',
                'organName': item['organType'],
                'profileImage': (item['User']?['profilePicturePath'] != null &&
                        item['User']['profilePicturePath'].isNotEmpty &&
                        Uri.tryParse(
                                    '${dotenv.env['API_URL']}/profilePictures/${item['User']['profilePicturePath']}')
                                ?.isAbsolute ==
                            true)
                    ? '${dotenv.env['API_URL']}/profilePictures/${item['User']['profilePicturePath']}'
                    : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                'note': item['note'],
              };
            }).toList());
          }
          totalItems = response.data['totalItems'];
          isLoading = false;
          isFetchingMore = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } on DioException catch (e) {
      print('Error fetching donation requests: $e');
      if (e.response?.statusCode == 201) {
        Future.delayed(Duration(seconds: 3), () {
          fetchDonationRequests();
        });
      } else {
        // Handle other error cases if needed
        throw Exception('Error fetching data: ${e.response?.statusMessage}');
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
      });
      await fetchDonationRequests();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 1;
    });
    await fetchDonationRequests();
  }

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
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
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
                      fetchDonationRequests();
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
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
                          fetchDonationRequests();
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
          isLoading
              ? Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: donationRequests.isEmpty
                      ? Center(child: Text('No donation requests found.'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                !isFetchingMore) {
                              _loadMore();
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: donationRequests.length + 1,
                              itemBuilder: (context, index) {
                                if (index == donationRequests.length) {
                                  return _buildProgressIndicator();
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      showDonationDetails(
                                          context, donationRequests[index]);
                                    },
                                    child: DonationCard(
                                      name: donationRequests[index]['name'],
                                      location: donationRequests[index]
                                          ['location'],
                                      timeAgo: _calculateTimeAgo(
                                          donationRequests[index]['timeAgo']),
                                      organImage: donationRequests[index]
                                          ['organImage'],
                                      organName: donationRequests[index]
                                          ['organName'],
                                      profileImage: donationRequests[index]
                                          ['profileImage'],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                ),
        ],
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
}
