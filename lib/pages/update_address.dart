import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/dio_client.dart';
import '../components/custom_show_dialog.dart';
import '../components/appbar.dart';
import 'package:dio/dio.dart';

class UpdateAddressPage extends StatefulWidget {
  @override
  State<UpdateAddressPage> createState() => _UpdateAddressPageState();
}

class _UpdateAddressPageState extends State<UpdateAddressPage> {
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();

  final LocationService locationService = LocationService();

  List<dynamic> provinces = [];
  List<dynamic> regencies = [];
  List<dynamic> districts = [];
  List<dynamic> villages = [];

  String? selectedProvinceId;
  String? selectedProvinceName;
  String? selectedRegencyId;
  String? selectedRegencyName;
  String? selectedDistrictId;
  String? selectedDistrictName;
  String? selectedVillageId;
  String? selectedVillageName;

  bool isLoading = false;
  bool isEditing = false;
  bool isSubmittingError = false;
  String? submittingErrorMessage;

  Map<String, dynamic>? addressData;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
    fetchAddress();
  }

  Future<void> fetchProvinces() async {
    try {
      setState(() {
        isLoading = true;
      });
      provinces = await locationService.fetchProvinces();
    } catch (e) {
      print('Error fetching provinces: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRegencies(String provinceId) async {
    try {
      setState(() {
        isLoading = true;
      });
      regencies = await locationService.fetchRegencies(provinceId);
      setState(() {
        selectedRegencyId = null;
        selectedRegencyName = null;
        selectedDistrictId = null;
        selectedDistrictName = null;
        selectedVillageId = null;
        selectedVillageName = null;
        districts = [];
        villages = [];
      });
    } catch (e) {
      print('Error fetching regencies: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDistricts(String regencyId) async {
    try {
      setState(() {
        isLoading = true;
      });
      districts = await locationService.fetchDistricts(regencyId);
      setState(() {
        selectedDistrictId = null;
        selectedDistrictName = null;
        selectedVillageId = null;
        selectedVillageName = null;
        villages = [];
      });
    } catch (e) {
      print('Error fetching districts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVillages(String districtId) async {
    try {
      setState(() {
        isLoading = true;
      });
      villages = await locationService.fetchVillages(districtId);
      setState(() {
        selectedVillageId = null;
        selectedVillageName = null;
      });
    } catch (e) {
      print('Error fetching villages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAddress() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await DioClient.instance.get('/api/user/address');
      if (response.statusCode == 200) {
        addressData = response.data['address'];
        streetNameController.text = addressData!['streetName'];
        postalCodeController.text = addressData!['postalCode'];
        houseNumberController.text = addressData!['houseNumber'];
      } else {
        showErrorDialog(
            context, 'Failed to fetch address', 'assets/svg/error.svg');
      }
    } catch (e) {
      print('Error fetching address: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAddress() async {
    setState(() {
      isSubmittingError = false;
      submittingErrorMessage = null;
    });

    final url = '/api/user/address';

    try {
      setState(() {
        isLoading = true;
      });

      final response = await DioClient.instance.put(
        url,
        data: {
          'province': selectedProvinceName,
          'city': selectedRegencyName,
          'district': selectedDistrictName,
          'subdistrict': selectedVillageName,
          'streetName': streetNameController.text,
          'postalCode': postalCodeController.text,
          'houseNumber': houseNumberController.text,
        },
      );

      if (response.statusCode == 200) {
        showSuccessDialog(context, 'Address Updated', 'assets/svg/complete.svg',
            '/Dashboard');
      } else {
        showErrorDialog(
            context, 'Failed to update address', 'assets/svg/error.svg');
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, '/Profile', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Update Address"),
        backgroundColor: Colors.white,
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isEditing ? buildEditForm() : buildAddressDetails(),
                ),
        ),
      ),
    );
  }

  Widget buildAddressDetails() {
    if (addressData == null) {
      return CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDetailRow(Icons.location_city, 'City', addressData!['city']),
        buildDetailRow(Icons.map, 'Province', addressData!['province']),
        buildDetailRow(Icons.location_on, 'District', addressData!['district']),
        buildDetailRow(Icons.home, 'Subdistrict', addressData!['subdistrict']),
        buildDetailRow(
            Icons.streetview, 'Street Name', addressData!['streetName']),
        buildDetailRow(
            Icons.post_add, 'Postal Code', addressData!['postalCode']),
        buildDetailRow(
            Icons.house, 'House Number', addressData!['houseNumber']),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEditing = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'Edit Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
    );
  }

  Widget buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Color(0xFFFF2156)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87)),
                SizedBox(height: 4),
                Text(value,
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildProvinceDropdown(),
          SizedBox(height: 25),
          buildRegencyDropdown(),
          SizedBox(height: 25),
          buildDistrictDropdown(),
          SizedBox(height: 25),
          buildVillageDropdown(),
          SizedBox(height: 25),
          TextFormField(
            controller: streetNameController,
            decoration: InputDecoration(
              labelText: 'Street Name',
              labelStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 25),
          TextFormField(
            controller: postalCodeController,
            decoration: InputDecoration(
              labelText: 'Postal Code',
              labelStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 25),
          TextFormField(
            controller: houseNumberController,
            decoration: InputDecoration(
              labelText: 'House Number',
              labelStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: updateAddress,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
          SizedBox(height: 10),
          if (isSubmittingError)
            Text(
              submittingErrorMessage ?? '',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedProvinceName,
      hint: Text('Select Province'),
      items: provinces.map((province) {
        return DropdownMenuItem<String>(
          value: province['name'],
          child: Text(province['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedProvinceName = value;
          selectedProvinceId =
              provinces.firstWhere((p) => p['name'] == value)['id'];
          fetchRegencies(selectedProvinceId!);
        });
      },
      decoration: InputDecoration(
        labelText: 'Province',
        labelStyle: TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget buildRegencyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRegencyName,
      hint: Text('Select City'),
      items: regencies.map((regency) {
        return DropdownMenuItem<String>(
          value: regency['name'],
          child: Text(regency['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRegencyName = value;
          selectedRegencyId =
              regencies.firstWhere((r) => r['name'] == value)['id'];
          fetchDistricts(selectedRegencyId!);
        });
      },
      decoration: InputDecoration(
        labelText: 'City',
        labelStyle: TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistrictName,
      hint: Text('Select District'),
      items: districts.map((district) {
        return DropdownMenuItem<String>(
          value: district['name'],
          child: Text(district['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDistrictName = value;
          selectedDistrictId =
              districts.firstWhere((d) => d['name'] == value)['id'];
          fetchVillages(selectedDistrictId!);
        });
      },
      decoration: InputDecoration(
        labelText: 'District',
        labelStyle: TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget buildVillageDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedVillageName,
      hint: Text('Select Village'),
      items: villages.map((village) {
        return DropdownMenuItem<String>(
          value: village['name'],
          child: Text(village['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedVillageName = value;
          selectedVillageId =
              villages.firstWhere((v) => v['name'] == value)['id'];
        });
      },
      decoration: InputDecoration(
        labelText: 'Village',
        labelStyle: TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
