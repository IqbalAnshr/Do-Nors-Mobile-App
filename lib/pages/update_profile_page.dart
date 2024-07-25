import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/dio_client.dart';
import '../components/custom_show_dialog.dart';
import '../components/appbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhoneNumber = false;
  bool _isEditingPassword = false;
  bool _isLoading = false;
  XFile? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient.instance.get('/api/user');
      if (response.statusCode == 200) {
        final data = response.data['user'];
        setState(() {
          _nameController.text = data['name'];
          _emailController.text = data['email'];
          _phoneNumberController.text = data['phoneNumber'];
          _profileImageUrl = (data['profilePicturePath'] != null &&
                  data['profilePicturePath'].isNotEmpty &&
                  Uri.tryParse(
                              '${dotenv.env['API_URL']}/profilePictures/${data['profilePicturePath']}')
                          ?.isAbsolute ==
                      true)
              ? '${dotenv.env['API_URL']}/profilePictures/${data['profilePicturePath']}'
              : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
        });
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final Map<String, dynamic> data = {};
    if (_isEditingName) data['name'] = _nameController.text;
    if (_isEditingEmail) data['email'] = _emailController.text;
    if (_isEditingPhoneNumber)
      data['phoneNumber'] = _phoneNumberController.text;
    if (_isEditingPassword && _passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }

    bool isProfileImageUpdated = _profileImage != null;

    if (data.isNotEmpty || isProfileImageUpdated) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update profile details if data is not empty
        if (data.isNotEmpty) {
          final response = await DioClient.instance.put(
            '/api/user',
            data: data,
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to update profile details');
          }
        }

        // Update profile picture if it is provided
        if (isProfileImageUpdated) {
          FormData formData = FormData();
          if (kIsWeb) {
            formData.files.add(MapEntry(
              'profilePicture',
              MultipartFile.fromBytes(
                await _profileImage!.readAsBytes(),
                filename: _profileImage!.name,
              ),
            ));
          } else {
            formData.files.add(MapEntry(
              'profilePicture',
              await MultipartFile.fromFile(_profileImage!.path),
            ));
          }

          final response = await DioClient.instance.put(
            '/api/user/profile-picture',
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
            ),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to update profile picture');
          }
        }

        showSuccessDialog(
          context,
          'Profile Updated',
          'assets/svg/complete.svg',
          '/Dashboard',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          showErrorDialog(
            context,
            '${e.response?.data['message']}',
            'assets/svg/error.svg',
          );
        } else {
          showErrorDialog(
            context,
            'An error occurred, please try again',
            'assets/svg/error.svg',
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/Profile');
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Update Profile"),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildProfileImageField(),
                SizedBox(height: 20),
                _buildProfileField(
                  'Name',
                  _nameController,
                  _isEditingName,
                  'Edit Name',
                  () {
                    setState(() {
                      _isEditingName = !_isEditingName;
                    });
                  },
                ),
                SizedBox(height: 15),
                _buildProfileField(
                  'Email',
                  _emailController,
                  _isEditingEmail,
                  'Edit Email',
                  () {
                    setState(() {
                      _isEditingEmail = !_isEditingEmail;
                    });
                  },
                ),
                SizedBox(height: 15),
                _buildProfileField(
                  'Phone Number',
                  _phoneNumberController,
                  _isEditingPhoneNumber,
                  'Edit Phone Number',
                  () {
                    setState(() {
                      _isEditingPhoneNumber = !_isEditingPhoneNumber;
                    });
                  },
                ),
                SizedBox(height: 15),
                if (_isEditingPassword)
                  _buildTextField(
                    'Password (leave blank to keep unchanged)',
                    _passwordController,
                    obscureText: true,
                  ),
                SizedBox(height: 30),
                if (_isEditingPassword ||
                    _isEditingName ||
                    _isEditingEmail ||
                    _isEditingPhoneNumber ||
                    _profileImage != null)
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2156),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    bool isEditing,
    String editText,
    VoidCallback onEdit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                    : Text(
                        '${controller.text}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
              ),
              if (!isEditing)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: const Color(0xFFFF2156),
                  ),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profileImage != null
                  ? FileImage(File(_profileImage!.path))
                  : (_profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null),
              child: _profileImage == null
                  ? Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
