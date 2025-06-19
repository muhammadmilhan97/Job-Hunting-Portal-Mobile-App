import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../models/job_model.dart';
import '../../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'job_seeker_profile_screen.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  State<JobSeekerHomeScreen> createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'IT',
    'Marketing',
    'Sales',
    'Design',
    'Education',
    'Healthcare',
    'Other'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCategoryItem(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          category,
          style: kBodyTextStyle.copyWith(
            color: isSelected ? Colors.white : kSecondaryTextColor,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: const Color(0xFFFAF9FE),
      elevation: 0,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to job details
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: kAccentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.work, color: kAccentColor),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? '',
                          style: kTitleTextStyle.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (job['type'] != null) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: kAccentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              job['type'],
                              style: kBodyTextStyle.copyWith(
                                color: kAccentColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16.sp,
                    color: kSecondaryTextColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    job['location'] ?? '',
                    style: kBodyTextStyle.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'PKR ${job['salary'] ?? ''}',
                    style: kBodyTextStyle.copyWith(
                      color: kAccentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<AuthProvider>(context).userProfile;
    final String userName;
    if (userProfile?.userType == 'job_seeker') {
      userName = userProfile?.name ?? 'Job Seeker';
    } else {
      userName = userProfile?.name ?? 'Job Seeker';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: kPrimaryTextColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobSeekerProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: kPrimaryTextColor),
            onPressed: () async {
              final provider =
                  Provider.of<AuthProvider>(context, listen: false);
              await provider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: kBodyTextStyle.copyWith(color: kSecondaryTextColor),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    userName,
                    style: kHeadingTextStyle,
                  ),
                  SizedBox(height: 16.h),
                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search jobs...',
                    prefixIcon: Icon(Icons.search, color: kSecondaryTextColor),
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ],
              ),
            ),

            // Categories Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: kTitleTextStyle),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return _buildCategoryItem(category, isSelected);
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Recent Jobs Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Jobs', style: kTitleTextStyle),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('jobs')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final jobs = snapshot.data!.docs;

                          if (jobs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_off,
                                      size: 64.sp, color: kSecondaryTextColor),
                                  SizedBox(height: 16.h),
                                  Text('No jobs found',
                                      style: kBodyTextStyle.copyWith(
                                          color: kSecondaryTextColor)),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                              final job =
                                  jobs[index].data() as Map<String, dynamic>;
                              return _buildJobCard(job);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
