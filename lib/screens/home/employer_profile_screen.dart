import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../services/cloudinary_service.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _companyAddressController;
  String? _companyLogoUrl;
  bool _isLoading = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    final userProfile =
        Provider.of<AuthProvider>(context, listen: false).userProfile;
    _uid = userProfile?.uid;
    _companyNameController = TextEditingController();
    _companyAddressController = TextEditingController();
  }

  Future<void> _loadProfile() async {
    if (_uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _companyNameController.text = data['profileData']?['companyName'] ?? '';
        _companyAddressController.text =
            data['profileData']?['companyAddress'] ?? '';
        _companyLogoUrl = data['profileData']?['companyLogo'];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _pickAndUploadLogo(String uid) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      final file = File(result.files.single.path!);
      final url = await uploadImageToCloudinary(file);
      if (url != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'profileData.companyLogo': url,
          });
          setState(() {
            _companyLogoUrl = url;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo uploaded successfully!')),
          );
        } catch (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save logo: $e')),
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
    await _loadProfile();
  }

  Future<void> _saveProfile(String uid) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileData.companyName': _companyNameController.text.trim(),
        'profileData.companyAddress': _companyAddressController.text.trim(),
      });
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
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
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48.w,
                        backgroundColor: kAccentColor.withOpacity(0.1),
                        backgroundImage:
                            _companyLogoUrl != null && _companyLogoUrl != ''
                                ? NetworkImage(_companyLogoUrl!)
                                : null,
                        child: _companyLogoUrl == null || _companyLogoUrl == ''
                            ? Icon(Icons.business,
                                color: kAccentColor, size: 48.w)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => _pickAndUploadLogo(_uid!),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: kAccentColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 20.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: _companyNameController,
                  hintText: 'Company Name',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter company name' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _companyAddressController,
                  hintText: 'Company Address',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter company address' : null,
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: _isLoading ? 'Saving...' : 'Save Profile',
                  onPressed: _isLoading ? null : () => _saveProfile(_uid!),
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
