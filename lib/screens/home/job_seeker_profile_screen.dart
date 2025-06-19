import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../services/cloudinary_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;
  late TextEditingController _expectedSalaryController;
  String? _cvUrl;
  bool _isLoading = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    final userProfile =
        Provider.of<AuthProvider>(context, listen: false).userProfile;
    _uid = userProfile?.uid;
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _addressController = TextEditingController();
    _experienceController = TextEditingController();
    _expectedSalaryController = TextEditingController();
  }

  Future<void> _loadProfile() async {
    if (_uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _cityController.text = data['profileData']?['city'] ?? '';
        _countryController.text = data['profileData']?['country'] ?? '';
        _addressController.text = data['profileData']?['address'] ?? '';
        _experienceController.text = data['profileData']?['experience'] ?? '';
        _expectedSalaryController.text =
            data['profileData']?['expectedSalary'] ?? '';
        _cvUrl = data['profileData']?['cvUrl'];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _pickAndUploadCV(String uid) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      final file = File(result.files.single.path!);
      print('Picked file: ${file.path}');
      final url = await uploadCVToCloudinary(file);
      print('Cloudinary returned URL: $url');
      if (url != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'profileData.cvUrl': url,
          });
          setState(() {
            _cvUrl = url;
            _isLoading = false;
          });
          print('CV URL saved to Firestore for user $uid');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CV uploaded successfully!')),
          );
        } catch (e) {
          setState(() => _isLoading = false);
          print('Error saving CV URL to Firestore: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save CV URL: $e')),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
    await _loadProfile(); // Always reload after upload
  }

  Future<void> _saveProfile(String uid) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'profileData.city': _cityController.text.trim(),
        'profileData.country': _countryController.text.trim(),
        'profileData.address': _addressController.text.trim(),
        'profileData.experience': _experienceController.text.trim(),
        'profileData.expectedSalary': _expectedSalaryController.text.trim(),
      });
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
      await _loadProfile(); // Always reload after save
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: kAccentColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _cityController,
                  hintText: 'City',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your city' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _countryController,
                  hintText: 'Country',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your country' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _addressController,
                  hintText: 'Address',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your address' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _experienceController,
                  hintText: 'Experience',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your experience' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _expectedSalaryController,
                  hintText: 'Expected Salary',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter expected salary' : null,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _cvUrl == null ? 'Upload CV' : 'Update CV',
                        onPressed:
                            _isLoading ? null : () => _pickAndUploadCV(_uid!),
                        isLoading: _isLoading,
                        backgroundColor: kAccentColor,
                        textColor: Colors.white,
                      ),
                    ),
                    if (_cvUrl != null && _cvUrl!.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye,
                            color: kAccentColor),
                        onPressed: () async {
                          final url = _cvUrl!;
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not open CV URL.')),
                            );
                          }
                        },
                      ),
                    ]
                  ],
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: 'Save Profile',
                  onPressed: _isLoading ? null : () => _saveProfile(_uid!),
                  isLoading: _isLoading,
                  backgroundColor: kAccentColor,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
