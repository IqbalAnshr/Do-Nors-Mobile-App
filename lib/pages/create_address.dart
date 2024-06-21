import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/location_service.dart';

class CreateAddressPage extends StatefulWidget {
  @override
  State<CreateAddressPage> createState() => _CreateAddressPageState();
}

class _CreateAddressPageState extends State<CreateAddressPage> {
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();

  final LocationService locationService = LocationService();

  List<dynamic> provinces = [];
  List<dynamic> regencies = [];
  List<dynamic> districts = [];
  List<dynamic> villages = [];

  String? selectedProvince;
  String? selectedRegency;
  String? selectedDistrict;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    provinces = await locationService.fetchProvinces();
    setState(() {});
  }

  Future<void> fetchRegencies(String provinceId) async {
    regencies = await locationService.fetchRegencies(provinceId);
    setState(() {});
  }

  Future<void> fetchDistricts(String regencyId) async {
    districts = await locationService.fetchDistricts(regencyId);
    setState(() {});
  }

  Future<void> fetchVillages(String districtId) async {
    villages = await locationService.fetchVillages(districtId);
    setState(() {});
  }

  Future<void> submitAddress(BuildContext context) async {
    final url = '${dotenv.env['API_URL']}/api/user/address';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'province': selectedProvince,
        'city': selectedRegency,
        'district': selectedDistrict,
        'subdistrict': selectedVillage,
        'streetName': streetNameController.text,
        'postalCode': postalCodeController.text,
        'houseNumber': houseNumberController.text,
      }),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token':
            'Bearer ${await SharedPreferences.getInstance().then((prefs) => prefs.getString('accessToken'))}',
      },
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Address Added'),
          content: Text('Your address has been added successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushNamed(context, '/Dashboard');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final errorMsg = response.statusCode == 400
          ? json.decode(response.body)['errors'][0]['msg']
          : json.decode(response.body)['error'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Address Addition Failed'),
          content: Text('Error: $errorMsg'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Address'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  buildProvinceDropdown(),
                  SizedBox(height: 20),
                  buildRegencyDropdown(),
                  SizedBox(height: 20),
                  buildDistrictDropdown(),
                  SizedBox(height: 20),
                  buildVillageDropdown(),
                  SizedBox(height: 20),
                  buildTextField('Street Name', streetNameController),
                  buildTextField('Postal Code', postalCodeController),
                  buildTextField('House Number', houseNumberController),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => submitAddress(context),
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
      ),
    );
  }

  Widget buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      items: provinces.map((province) {
        return DropdownMenuItem<String>(
          value: province['id'],
          child: Text(province['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedProvince = value;
          fetchRegencies(value!);
        });
      },
      value: selectedProvince,
      decoration: InputDecoration(
        labelText: 'Province',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildRegencyDropdown() {
    return DropdownButtonFormField<String>(
      items: regencies.map((regency) {
        return DropdownMenuItem<String>(
          value: regency['id'],
          child: Text(regency['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRegency = value;
          fetchDistricts(value!);
        });
      },
      value: selectedRegency,
      decoration: InputDecoration(
        labelText: 'Regency',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      items: districts.map((district) {
        return DropdownMenuItem<String>(
          value: district['id'],
          child: Text(district['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDistrict = value;
          fetchVillages(value!);
        });
      },
      value: selectedDistrict,
      decoration: InputDecoration(
        labelText: 'District',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildVillageDropdown() {
    return DropdownButtonFormField<String>(
      items: villages.map((village) {
        return DropdownMenuItem<String>(
          value: village['id'],
          child: Text(village['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedVillage = value;
        });
      },
      value: selectedVillage,
      decoration: InputDecoration(
        labelText: 'Village',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
