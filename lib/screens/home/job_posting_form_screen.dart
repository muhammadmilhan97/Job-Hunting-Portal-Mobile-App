import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobPostingFormScreen extends StatefulWidget {
  final String? jobId;
  final Map<String, dynamic>? initialData;
  const JobPostingFormScreen({super.key, this.jobId, this.initialData});

  @override
  State<JobPostingFormScreen> createState() => _JobPostingFormScreenState();
}

class _JobPostingFormScreenState extends State<JobPostingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedCategory = 'IT';
  String _selectedGender = 'Any';
  String _selectedType = 'Full-time';
  bool _isLoading = false;

  final List<String> _categories = ['IT', 'Education', 'Marketing', 'SEO'];
  final List<String> _genders = ['Any', 'Male', 'Female'];
  final List<String> _types = ['Full-time', 'Part-time', 'Freelance'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = Map<String, dynamic>.from(widget.initialData!);
      data.remove('timestamp');
      _titleController.text = data['title'] ?? '';
      _positionController.text = data['position'] ?? '';
      _salaryController.text = data['salary'] ?? '';
      _locationController.text = data['location'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _requirementsController.text = data['requirements'] ?? '';
      _ageController.text = data['age'] ?? '';
      _selectedCategory = data['category'] ?? 'IT';
      _selectedGender = data['gender'] ?? 'Any';
      _selectedType = data['type'] ?? 'Full-time';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not authenticated');

        // Get user profile to get company name
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>;
        final companyName = userData['profileData']?['companyName'] ?? '';

        final Map<String, dynamic> jobData = {
          'title': _titleController.text.trim(),
          'category': _selectedCategory,
          'position': _positionController.text.trim(),
          'salary': _salaryController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'requirements': _requirementsController.text.trim(),
          'gender': _selectedGender,
          'age': _ageController.text.trim(),
          'type': _selectedType,
          'postedBy': user.uid,
          'company': companyName,
          'timestamp': FieldValue.serverTimestamp(),
        };

        if (widget.jobId != null) {
          // Update existing job
          await FirebaseFirestore.instance
              .collection('jobs')
              .doc(widget.jobId)
              .update(jobData);
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job updated successfully!')),
            );
            Navigator.pop(context);
          }
        } else {
          // Create new job
          final docRef =
              await FirebaseFirestore.instance.collection('jobs').add(jobData);
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job posted successfully!')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post job: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Job', style: kTitleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  hintText: 'Job Title',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter job title'
                      : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: InputDecoration(
                    labelText: 'Job Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _positionController,
                  hintText: 'Position',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter position'
                      : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _salaryController,
                  hintText: 'Salary',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter salary'
                      : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _locationController,
                  hintText: 'Location',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter location'
                      : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Job Description',
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter job description'
                      : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _requirementsController,
                  hintText: 'Job Requirements',
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter job requirements'
                      : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  decoration: InputDecoration(
                    labelText: 'Gender Preference',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _ageController,
                  hintText: 'Age Preference (e.g. 18-30)',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter age preference'
                      : null,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                  decoration: InputDecoration(
                    labelText: 'Type of Employment',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: 'Post Job',
                  onPressed: _submit,
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
