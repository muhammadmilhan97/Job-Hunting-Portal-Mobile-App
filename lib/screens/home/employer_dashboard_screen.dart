import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_button.dart';
import '../../constants.dart';
import 'job_posting_form_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as local_auth;
import '../auth/login_screen.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userProfile =
        Provider.of<local_auth.AuthProvider>(context).userProfile;
    final companyName = userProfile?.companyName ?? 'Employer';
    final companyLogo = userProfile?.profileData['companyLogo'];
    print('DEBUG: Current user UID: \\${currentUser?.uid}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Employer Dashboard', style: kTitleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.logout, color: kPrimaryTextColor),
              onPressed: () async {
                final provider = Provider.of<local_auth.AuthProvider>(context,
                    listen: false);
                await provider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: kSilverColor,
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: kAccentColor.withOpacity(0.1),
                    backgroundImage: companyLogo != null && companyLogo != ''
                        ? NetworkImage(companyLogo)
                        : null,
                    child: companyLogo == null || companyLogo == ''
                        ? Icon(Icons.business, color: kAccentColor, size: 32)
                        : null,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: kSubTitleTextStyle.copyWith(
                              color: kSecondaryTextColor),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          companyName,
                          style: kHeadingTextStyle.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Manage your job postings and applicants here.',
                style: kSubTitleTextStyle.copyWith(color: kSecondaryTextColor),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomButton(
                text: 'Post a Job',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const JobPostingFormScreen()),
                  );
                },
                backgroundColor: kAccentColor,
                textColor: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Divider(
              color: kSecondaryTextColor.withOpacity(0.15),
              thickness: 1,
              height: 1,
              indent: 24.w,
              endIndent: 24.w,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('postedBy',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_outline,
                                size: 64, color: kAccentColor.withOpacity(0.2)),
                            SizedBox(height: 16.h),
                            Text(
                              'Your posted jobs will appear here.',
                              style: kBodyTextStyle.copyWith(
                                  color: kSecondaryTextColor),
                            ),
                          ],
                        ),
                      );
                    }
                    final jobs = snapshot.data!.docs;
                    return ListView.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final job = jobs[index].data() as Map<String, dynamic>;
                        job['docId'] = jobs[index].id;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailScreen(job: job),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.work,
                                        color: kAccentColor, size: 22),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        job['title'] ?? '',
                                        style: kTitleTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kAccentColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        job['type'] ?? '',
                                        style: kBodyTextStyle.copyWith(
                                            color: kAccentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  job['category'] ?? '',
                                  style: kSubTitleTextStyle.copyWith(
                                      color: kAccentColor),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  job['description'] ?? '',
                                  style: kBodyTextStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16, color: kSecondaryTextColor),
                                    SizedBox(width: 4.w),
                                    Text(job['location'] ?? '',
                                        style: kBodyTextStyle),
                                    Spacer(),
                                    Text('PKR',
                                        style: kBodyTextStyle.copyWith(
                                            color: kSecondaryTextColor,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 2.w),
                                    Text(job['salary'] ?? '',
                                        style: kBodyTextStyle),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// JobDetailScreen to show full job details
class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailScreen({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSilverColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(job['title'] ?? 'Job Details', style: kTitleTextStyle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: kAccentColor, size: 32),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              job['title'] ?? '',
                              style: kTitleTextStyle,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kAccentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              job['type'] ?? '',
                              style: kBodyTextStyle.copyWith(
                                  color: kAccentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(job['category'] ?? '',
                          style:
                              kSubTitleTextStyle.copyWith(color: kAccentColor)),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 18, color: kSecondaryTextColor),
                          SizedBox(width: 4.w),
                          Text(job['location'] ?? '', style: kBodyTextStyle),
                          Spacer(),
                          Text('PKR',
                              style: kBodyTextStyle.copyWith(
                                  color: kSecondaryTextColor,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 2.w),
                          Text(job['salary'] ?? '', style: kBodyTextStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Details Card
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description', style: kSubTitleTextStyle),
                          SizedBox(height: 6.h),
                          Text(job['description'] ?? '', style: kBodyTextStyle),
                          SizedBox(height: 16.h),
                          Text('Requirements', style: kSubTitleTextStyle),
                          SizedBox(height: 6.h),
                          Text(job['requirements'] ?? '',
                              style: kBodyTextStyle),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 18, color: kSecondaryTextColor),
                              SizedBox(width: 4.w),
                              Text('Gender: ${job['gender'] ?? ''}',
                                  style: kBodyTextStyle),
                              Spacer(),
                              Icon(Icons.cake,
                                  size: 18, color: kSecondaryTextColor),
                              SizedBox(width: 4.w),
                              Text('Age: ${job['age'] ?? ''}',
                                  style: kBodyTextStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Footer Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Navigate to the job posting form with pre-filled data for editing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobPostingFormScreen(
                              jobId: job['id'] ?? job['docId'],
                              initialData: job,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final jobId = job['id'] ?? job['docId'];
                        if (jobId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job ID not found.')),
                          );
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Job'),
                            content: const Text(
                                'Are you sure you want to delete this job?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('jobs')
                                .doc(jobId)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Job deleted successfully.')),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete job: \\${e.toString()}')),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.delete),
                      label: Text('Delete Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
