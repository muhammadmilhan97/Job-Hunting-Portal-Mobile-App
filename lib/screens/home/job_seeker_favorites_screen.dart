import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../models/job.dart';
import '../../services/favorites_service.dart';
import '../../services/job_service.dart';
import '../detail/detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class JobSeekerFavoritesScreen extends StatefulWidget {
  const JobSeekerFavoritesScreen({super.key});

  @override
  State<JobSeekerFavoritesScreen> createState() =>
      _JobSeekerFavoritesScreenState();
}

class _JobSeekerFavoritesScreenState extends State<JobSeekerFavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final JobService _jobService = JobService();

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<AuthProvider>(context).userProfile;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Favorites', style: kTitleTextStyle),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: kPrimaryTextColor),
        ),
        body: Center(
          child: Text('Please log in to view favorites', style: kBodyTextStyle),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites', style: kTitleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _favoritesService.getUserFavorites(userProfile.uid),
          builder: (context, favoritesSnapshot) {
            if (favoritesSnapshot.hasError) {
              return Center(
                child: Text('Error: ${favoritesSnapshot.error}',
                    style: kBodyTextStyle),
              );
            }

            if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final favorites = favoritesSnapshot.data!.docs;

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64.sp,
                      color: kSecondaryTextColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No favorite jobs yet',
                      style:
                          kTitleTextStyle.copyWith(color: kSecondaryTextColor),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap the heart icon on any job to add it to favorites',
                      style:
                          kBodyTextStyle.copyWith(color: kSecondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite =
                    favorites[index].data() as Map<String, dynamic>;
                final jobId = favorite['jobId'] as String;

                return FutureBuilder<DocumentSnapshot>(
                  future: _jobService.getJobById(jobId),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.hasError) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: ListTile(
                          leading: Icon(Icons.error, color: Colors.red),
                          title:
                              Text('Error loading job', style: kBodyTextStyle),
                          subtitle: Text('Job may have been deleted',
                              style: kCaptionTextStyle),
                        ),
                      );
                    }

                    if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: kSecondaryTextColor),
                          title: Text('Job not found', style: kBodyTextStyle),
                          subtitle: Text('This job may have been removed',
                              style: kCaptionTextStyle),
                        ),
                      );
                    }

                    final jobData =
                        jobSnapshot.data!.data() as Map<String, dynamic>;
                    jobData['docId'] = jobSnapshot.data!.id;

                    return _buildFavoriteJobCard(jobData);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteJobCard(Map<String, dynamic> job) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: const Color(0xFFFAF9FE),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailScreen(data: Job.fromMap(job, job['docId'] ?? '')),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                              color: kAccentColor.withAlpha(25),
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
                  Icon(
                    Icons.favorite,
                    color: kAccentColor,
                    size: 20.sp,
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
}
