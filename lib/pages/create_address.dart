import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/dio_client.dart';
import '../components/custom_show_dialog.dart';
import 'package:dio/dio.dart';

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

  String? selectedProvinceId;
  String? selectedProvinceName;
  String? selectedRegencyId;
  String? selectedRegencyName;
  String? selectedDistrictId;
  String? selectedDistrictName;
  String? selectedVillageId;
  String? selectedVillageName;

  bool isLoading = false;
  bool isSubmittingError = false;
  String? submittingErrorMessage;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
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

  Future<void> submitAddress(BuildContext context) async {
    setState(() {
      isSubmittingError = false;
      submittingErrorMessage = null;
    });

    final url = '/api/user/address';

    try {
      setState(() {
        isLoading = true;
      });

      final response = await DioClient.instance.post(
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

      if (response.statusCode == 201) {
        showSuccessDialog(
            context, 'Address Added', 'assets/svg/complete.svg', '/Dashboard');
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
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
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
                  SizedBox(height: 20),
                  if (isSubmittingError)
                    Text(
                      submittingErrorMessage ?? '',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
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
          selectedProvinceId = value;
          selectedProvinceName = provinces
              .firstWhere((province) => province['id'] == value)['name'];
          fetchRegencies(value!);
        });
      },
      value: selectedProvinceId,
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
          selectedRegencyId = value;
          selectedRegencyName =
              regencies.firstWhere((regency) => regency['id'] == value)['name'];
          fetchDistricts(value!);
        });
      },
      value: selectedRegencyId,
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
          selectedDistrictId = value;
          selectedDistrictName = districts
              .firstWhere((district) => district['id'] == value)['name'];
          fetchVillages(value!);
        });
      },
      value: selectedDistrictId,
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
          selectedVillageId = value;
          selectedVillageName =
              villages.firstWhere((village) => village['id'] == value)['name'];
        });
      },
      value: selectedVillageId,
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
