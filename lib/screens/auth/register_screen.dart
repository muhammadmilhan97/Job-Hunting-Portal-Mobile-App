import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  final String initialUserType;
  const RegisterScreen({super.key, this.initialUserType = 'job_seeker'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Job Seeker fields
  final _cnicController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  // Employer fields
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _contactNumberController = TextEditingController();

  bool _isLoading = false;
  late String _selectedUserType;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _selectedUserType = widget.initialUserType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cnicController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _expectedSalaryController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Collect profile data
        Map<String, dynamic> profileData = {};
        if (_selectedUserType == 'job_seeker') {
          profileData = {
            'cnic': _cnicController.text.trim(),
            'city': _cityController.text.trim(),
            'country': _countryController.text.trim(),
            'address': _addressController.text.trim(),
            'experience': _experienceController.text.trim(),
            'expectedSalary':
                _expectedSalaryController.text.trim().replaceAll(',', ''),
          };
        } else {
          profileData = {
            'companyName': _companyNameController.text.trim(),
            'companyAddress': _companyAddressController.text.trim(),
            'contactNumber': _contactNumberController.text.trim(),
          };
        }
        debugPrint(
            'Attempting registration with email: \'${_emailController.text.trim()}\'');
        await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _selectedUserType,
          profileData,
        );
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registration successful! Please sign in.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        // Clear Firebase state on failure
        await FirebaseAuth.instance.signOut();
        String errorMessage = e.toString();
        if (errorMessage.contains('email-already-in-use')) {
          errorMessage =
              'This email is already registered. Please sign in or use a different email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Create Account', style: kTitleTextStyle),
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          color: kSilverColor,
                          shape: BoxShape.circle,
                          boxShadow: [kCardShadow],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logojobhunt.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text('Job Hunting Portal', style: kHeadingTextStyle),
                      SizedBox(height: 8.h),
                      Text(
                        'Find Your Dream Job',
                        style: kSubTitleTextStyle.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Divider(
                  color: kSecondaryTextColor.withOpacity(0.15),
                  thickness: 1,
                ),
                SizedBox(height: 16.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 3,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hintText: _selectedUserType == 'employer'
                              ? 'Full Name (Contact Person)'
                              : 'Full Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        if (_selectedUserType == 'employer') ...[
                          CustomTextField(
                            controller: _companyNameController,
                            hintText: 'Company Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your company name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _companyAddressController,
                            hintText: 'Company Address',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your company address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _contactNumberController,
                            hintText: 'Contact Number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your contact number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                        ],
                        if (_selectedUserType == 'job_seeker') ...[
                          CustomTextField(
                            controller: _cnicController,
                            hintText: 'CNIC',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your CNIC';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _cityController,
                            hintText: 'City',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _countryController,
                            hintText: 'Country',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your country';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _addressController,
                            hintText: 'Address',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _experienceController,
                            hintText: 'Experience (years)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your experience';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _expectedSalaryController,
                            hintText: 'Expected Salary',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your expected salary';
                              }
                              return null;
                            },
                          ),
                        ],
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        CustomButton(
                          text: _isLoading ? 'Signing Up...' : 'Sign Up',
                          onPressed: _isLoading ? null : () => _register(),
                          backgroundColor: kAccentColor,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?',
                                style: kBodyTextStyle),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Sign In',
                                  style: kBodyTextStyle.copyWith(
                                      color: kAccentColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
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
}
