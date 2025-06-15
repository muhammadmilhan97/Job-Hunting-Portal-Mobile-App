import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: kSilverColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Home', style: kTitleTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: kPrimaryTextColor),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome ${authProvider.user?.email ?? "User"}!',
                style: kHeadingTextStyle,
              ),
              SizedBox(height: 16.h),
              Text(
                'You are now logged in to the Job Hunting Portal.',
                style: kSubTitleTextStyle.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
              // TODO: Add job listings and other features here
            ],
          ),
        ),
      ),
    );
  }
}
