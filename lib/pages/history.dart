import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_client.dart';
import '../components/appbar.dart';
import '../components/custom_show_dialog.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> requests = [];
  List<dynamic> donors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final requestResponse = await DioClient.instance.get('/api/user/request');
      final donorResponse = await DioClient.instance.get('/api/user/donor');

      if (requestResponse.statusCode == 200 &&
          donorResponse.statusCode == 200) {
        setState(() {
          requests = requestResponse.data['requests'];
          donors = donorResponse.data['donors'];
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        showErrorDialog(context, '${e.response?.data['errors'][0]['msg']}',
            'assets/svg/error.svg');
      } else {
        showErrorDialog(context, 'An error occurred, please try again',
            'assets/svg/error.svg');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(String type, int id) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = '/api/user/$type/$id';
      final response = await DioClient.instance.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          if (type == 'request') {
            requests.removeWhere((item) => item['id'] == id);
          } else if (type == 'donor') {
            donors.removeWhere((item) => item['id'] == id);
          }
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        showErrorDialog(context, '${e.response?.data['errors'][0]['msg']}',
            'assets/svg/error.svg');
      } else {
        showErrorDialog(context, 'An error occurred, please try again',
            'assets/svg/error.svg');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'History'),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requests',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 10),
                    requests.isEmpty
                        ? Text('No requests History')
                        : Column(
                            children: requests
                                .map((request) => buildRequestRow(request))
                                .toList(),
                          ),
                    SizedBox(height: 20),
                    Text('Donors',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 10),
                    donors.isEmpty
                        ? Text('No donors History')
                        : Column(
                            children: donors
                                .map((donor) => buildDonorRow(donor))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildRequestRow(dynamic request) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/${request['organType'].toLowerCase()}-organ.png',
              width: 75,
              height: 75,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request['hospital'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('City: ${request['city']}'),
                  Text('Organ: ${request['organType']}'),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xFFFF2156)),
              onPressed: () => deleteItem('request', request['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDonorRow(dynamic donor) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/${donor['organType'].toLowerCase()}-organ.png',
              width: 75,
              height: 75,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Organ: ${donor['organType']}'),
                  Text(donor['note']),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xFFFF2156)),
              onPressed: () => deleteItem('donor', donor['id']),
            ),
          ],
        ),
      ),
    );
  }
}
