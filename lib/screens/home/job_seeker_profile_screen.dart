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
import 'package:image_picker/image_picker.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _educationController;
  late TextEditingController _experienceController;
  late TextEditingController _expectedSalaryController;
  late TextEditingController _bioController;
  String? _profileImageUrl;
  String? _cvUrl;
  List<String> _skills = [];
  final List<String> _allSkills = [
    'Flutter',
    'Firebase',
    'React',
    'Node.js',
    'Python',
    'Dart',
    'UI/UX',
    'SQL',
    'Java',
    'C++',
    'AWS',
    'Figma',
    'Other'
  ];
  bool _isLoading = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    final userProfile =
        Provider.of<AuthProvider>(context, listen: false).userProfile;
    _uid = userProfile?.uid;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _addressController = TextEditingController();
    _educationController = TextEditingController();
    _experienceController = TextEditingController();
    _expectedSalaryController = TextEditingController();
    _bioController = TextEditingController();
  }

  Future<void> _loadProfile() async {
    if (_uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['profileData']?['phone'] ?? '';
        _cityController.text = data['profileData']?['city'] ?? '';
        _countryController.text = data['profileData']?['country'] ?? '';
        _addressController.text = data['profileData']?['address'] ?? '';
        _educationController.text = data['profileData']?['education'] ?? '';
        _experienceController.text =
            data['profileData']?['experience']?.toString() ?? '';
        _expectedSalaryController.text =
            data['profileData']?['expectedSalary']?.toString() ?? '';
        _bioController.text = data['profileData']?['bio'] ?? '';
        _profileImageUrl = data['profileData']?['profile_image_url'];
        _cvUrl = data['profileData']?['cvUrl'];
        _skills = (data['profileData']?['skills'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _pickAndUploadProfileImage(String uid) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _isLoading = true);
      final file = File(picked.path);
      final url = await uploadImageToCloudinary(file);
      if (url != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileData.profile_image_url': url,
        });
        setState(() {
          _profileImageUrl = url;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed.')),
        );
      }
    }
  }

  Future<void> _pickAndUploadCV(String uid) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = await file.length();
      final isPdf = fileName.toLowerCase().endsWith('.pdf');
      if (!isPdf) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only PDF files are allowed.')),
        );
        return;
      }
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size must be under 5MB.')),
        );
        return;
      }
      setState(() => _isLoading = true);
      final url = await uploadCVToCloudinary(file);
      if (url != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileData.cvUrl': url,
        });
        setState(() {
          _cvUrl = url;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploaded successfully!')),
        );
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

  Future<void> _deleteCV(String uid) async {
    if (_cvUrl == null || _cvUrl!.isEmpty) return;
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileData.cvUrl': FieldValue.delete(),
    });
    setState(() {
      _cvUrl = null;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CV deleted.')),
    );
  }

  void _resetForm() {
    _loadProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form reset.')),
    );
  }

  Future<void> _saveProfile(String uid) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final profileData = {
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'address': _addressController.text.trim(),
        'education': _educationController.text.trim(),
        'experience': _experienceController.text.trim(),
        'expectedSalary':
            int.tryParse(_expectedSalaryController.text.trim()) ?? 0,
        'bio': _bioController.text.trim(),
        'skills': _skills,
        'cvUrl': _cvUrl,
        'profile_image_url': _profileImageUrl,
      };
      await Provider.of<AuthProvider>(context, listen: false)
          .updateProfile(profileData);
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
        title: const Text('My Profile'),
        backgroundColor: kAccentColor,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48.r,
                              backgroundImage: _profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                              child: _profileImageUrl == null ||
                                      _profileImageUrl!.isEmpty
                                  ? Icon(Icons.person,
                                      size: 48.r, color: kSecondaryTextColor)
                                  : null,
                              backgroundColor: kSilverColor,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickAndUploadProfileImage(_uid!),
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
                      SizedBox(height: 16.h),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your name'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                readOnly: true,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _phoneController,
                                hintText: 'Phone',
                                prefixIcon: Icon(Icons.phone),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your phone'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _cityController,
                                hintText: 'City',
                                prefixIcon: Icon(Icons.location_city),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your city'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _countryController,
                                hintText: 'Country',
                                prefixIcon: Icon(Icons.flag),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your country'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _addressController,
                                hintText: 'Address',
                                prefixIcon: Icon(Icons.home),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: _educationController,
                                hintText: 'Education',
                                prefixIcon: Icon(Icons.school),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your education'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _experienceController,
                                hintText: 'Experience (years)',
                                prefixIcon: Icon(Icons.work),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter your experience'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _expectedSalaryController,
                                hintText: 'Expected Salary',
                                prefixIcon: Icon(Icons.attach_money),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter expected salary'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              Text('Skills', style: kSubTitleTextStyle),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                children: [
                                  ..._skills.map((skill) => Chip(
                                        label: Text(skill),
                                        onDeleted: () {
                                          setState(() {
                                            _skills.remove(skill);
                                          });
                                        },
                                      )),
                                  FilterChip(
                                    label: Text('Add Skill'),
                                    selected: false,
                                    onSelected: (_) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String customSkill = '';
                                          List<String> filteredSkills =
                                              _allSkills
                                                  .where((s) =>
                                                      !_skills.contains(s))
                                                  .toList();
                                          return StatefulBuilder(
                                            builder: (context, setStateDialog) {
                                              List<String> suggestions =
                                                  filteredSkills
                                                      .where((s) =>
                                                          customSkill.isEmpty ||
                                                          s.toLowerCase().contains(
                                                              customSkill
                                                                  .toLowerCase()))
                                                      .toList();
                                              return AlertDialog(
                                                title: Text('Add Skill'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      autofocus: true,
                                                      decoration:
                                                          InputDecoration(
                                                              hintText:
                                                                  'Enter skill'),
                                                      onChanged: (val) {
                                                        setStateDialog(() {
                                                          customSkill = val;
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(height: 12),
                                                    if (suggestions.isNotEmpty)
                                                      SizedBox(
                                                        height: 100,
                                                        child: ListView(
                                                          children: suggestions
                                                              .map((s) =>
                                                                  ListTile(
                                                                    title:
                                                                        Text(s),
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context,
                                                                          s);
                                                                    },
                                                                  ))
                                                              .toList(),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context,
                                                            customSkill),
                                                    child: Text('Add'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ).then((value) {
                                        if (value != null &&
                                            value
                                                .toString()
                                                .trim()
                                                .isNotEmpty &&
                                            !_skills.contains(value)) {
                                          setState(() {
                                            _skills
                                                .add(value.toString().trim());
                                          });
                                        }
                                      });
                                    },
                                    selectedColor: kAccentColor,
                                    checkmarkColor: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _bioController,
                                hintText: 'Short Bio',
                                prefixIcon: Icon(Icons.info_outline),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Resume (CV)', style: kSubTitleTextStyle),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.upload_file),
                                    label: Text('Upload CV'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kAccentColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _pickAndUploadCV(_uid!),
                                  ),
                                  if (_cvUrl != null && _cvUrl!.isNotEmpty)
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.remove_red_eye),
                                      label: Text('View CV'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: kAccentColor,
                                        side: BorderSide(color: kAccentColor),
                                      ),
                                      onPressed: () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(_cvUrl!))) {
                                          await launchUrl(Uri.parse(_cvUrl!));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Could not open CV URL.')),
                                          );
                                        }
                                      },
                                    ),
                                  if (_cvUrl != null && _cvUrl!.isNotEmpty)
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCV(_uid!),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Save Profile',
                              onPressed:
                                  _isLoading ? null : () => _saveProfile(_uid!),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CustomButton(
                              text: 'Reset',
                              color: Colors.grey[300],
                              textColor: Colors.black,
                              onPressed: _isLoading ? null : _resetForm,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
