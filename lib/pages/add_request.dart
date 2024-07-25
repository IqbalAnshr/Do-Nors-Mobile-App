import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_client.dart';
import '../components/appbar.dart';
import '../components/custom_show_dialog.dart';

class CreateRequestPage extends StatefulWidget {
  @override
  _CreateRequestPageState createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? selectedOrganType;
  List<String> organTypes = [
    'Liver',
    'Kidney',
    'Heart',
    'Lung',
    'Pancreas',
    'Intestine'
  ];

  bool isLoading = false;

  Future<void> createRequest() async {
    setState(() {
      isLoading = true;
    });

    final url = '/api/user/request/';

    try {
      final response = await DioClient.instance.post(
        url,
        data: {
          'city': cityController.text,
          'hospital': hospitalController.text,
          'organType': selectedOrganType,
          'phoneNumber': phoneNumberController.text,
          'note': noteController.text,
        },
      );

      if (response.statusCode == 201) {
        showSuccessDialog(context, 'Request Created Successfully',
            'assets/svg/complete.svg', '/Dashboard');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        showErrorDialog(context, '${e.response?.data['errors'][0]['msg']}',
            'assets/svg/error.svg');
      } else {
        showErrorDialog(context, 'An error occurred, please try again.',
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
      appBar: CustomAppBar(
        title: 'Create Request',
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                buildTextField('City', cityController,
                    Icon(Icons.location_on, color: Color(0xFFFF2156))),
                SizedBox(height: 20),
                buildTextField('Hospital', hospitalController,
                    Icon(Icons.local_hospital, color: Color(0xFFFF2156))),
                SizedBox(height: 20),
                buildDropdownField('Organ Type', organTypes, selectedOrganType,
                    (String? value) {
                  setState(() {
                    selectedOrganType = value;
                  });
                }, Icon(Icons.list_alt, color: Color(0xFFFF2156))),
                SizedBox(height: 20),
                buildTextField('Phone Number', phoneNumberController,
                    Icon(Icons.phone, color: Color(0xFFFF2156))),
                SizedBox(height: 20),
                buildTextField('Note', noteController, null, maxLines: 3),
                SizedBox(height: 30),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: createRequest,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2156),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, Icon? icon,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: icon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget buildDropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged, Icon? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: null,
            prefixIcon: icon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          hint: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
