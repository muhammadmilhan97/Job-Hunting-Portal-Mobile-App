import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';
import '../home/employer_dashboard_screen.dart';
import '../home/job_seeker_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _showSignUpBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How do you want to sign up?',
                style: kHeadingTextStyle.copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterScreen(initialUserType: 'job_seeker'),
                          ),
                        );
                      },
                      child: Text('Job Seeker',
                          style: kTitleTextStyle.copyWith(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterScreen(initialUserType: 'employer'),
                          ),
                        );
                      },
                      child: Text('Employer',
                          style: kTitleTextStyle.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        debugPrint(
            'Attempting login with email: \'${_emailController.text.trim()}\'');
        final userCredential = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (!mounted) return;
        debugPrint('Login successful for user: ${userCredential.user?.uid}');
        await _authService
            .getUserProfile(userCredential.user!.uid)
            .then((userProfile) {
          debugPrint(
              'Fetched user profile: ${userProfile != null ? userProfile.toMap().toString() : 'null'}');
          debugPrint('Detected userType: ${userProfile?.userType ?? 'null'}');
          setState(() => _isLoading = false);
          if (mounted) {
            if (userProfile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User profile not found.')),
              );
              return;
            }
            _navigateToDashboard(userProfile.userType);
          }
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        String errorMessage = e.toString();
        if (errorMessage.contains('user-not-found')) {
          errorMessage = 'No user found with this email. Please sign up first.';
        } else if (errorMessage.contains('wrong-password')) {
          errorMessage = 'Wrong password. Please try again.';
        } else if (errorMessage.contains('invalid-credential')) {
          errorMessage = 'Wrong password. Please try again.';
        } else if (errorMessage.contains('invalid-email')) {
          errorMessage = 'Invalid email format. Please check your email.';
        } else if (errorMessage.contains('user-disabled')) {
          errorMessage =
              'This account has been disabled. Please contact support.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _navigateToDashboard(String? userType) {
    if (userType == 'employer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const EmployerDashboardScreen()),
      );
    } else if (userType == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
        ),
      );
    } else {
      // Default to job seeker
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobSeekerHomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Sign In', style: kTitleTextStyle),
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
                  color: kSecondaryTextColor.withAlpha(38),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()),
                              );
                            },
                            child: Text('Forgot Password?',
                                style: kSubTitleTextStyle.copyWith(
                                    color: kAccentColor)),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomButton(
                          text: _isLoading ? 'Signing In...' : 'Sign In',
                          onPressed: _isLoading ? null : () => _login(),
                          backgroundColor: kAccentColor,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?',
                                style: kBodyTextStyle),
                            TextButton(
                              onPressed: () => _showSignUpBottomSheet(),
                              child: Text('Sign Up',
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

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin dashboard coming soon!')),
    );
  }
}
