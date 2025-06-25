import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_listing_app/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/job.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';

class DetailFooter extends StatefulWidget {
  final Job job;
  const DetailFooter({super.key, required this.job});

  @override
  State<DetailFooter> createState() => _DetailFooterState();
}

class _DetailFooterState extends State<DetailFooter> {
  bool _isLoading = false;

  Future<void> _applyForJob(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to apply.')),
      );
      return;
    }
    final cvUrl = user.profileData['cvUrl'] ?? '';
    final expectedSalary = user.expectedSalary ?? '';
    final experience = user.experience ?? '';
    final employerId = widget.job.postedBy ?? '';
    final userName = user.name;
    final jobTitle = widget.job.position;
    print(
        'DEBUG: Applying for job with employerId: $employerId, userName: $userName, jobTitle: $jobTitle');
    setState(() => _isLoading = true);
    try {
      await ApplicationService().submitApplication(
        jobId: widget.job.id.toString(),
        userId: user.uid,
        cvUrl: cvUrl,
        expectedSalary: expectedSalary,
        experience: experience,
        employerId: employerId,
        userName: userName,
        jobTitle: jobTitle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply: \\${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(kSpacingUnit * 2),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [kFooterShadow],
            ),
            child: Row(
              children: [
                Container(
                  height: kSpacingUnit * 6,
                  width: kSpacingUnit * 8,
                  decoration: BoxDecoration(
                    color: kSilverColor,
                    borderRadius: BorderRadius.circular(kSpacingUnit * 3),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/heart_icon.svg',
                      color: kAccentColor,
                      height: 20.sp,
                      width: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: kSpacingUnit * 2),
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : () => _applyForJob(context),
                    child: Container(
                      height: kSpacingUnit * 6,
                      width: kSpacingUnit * 8,
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(kSpacingUnit * 3),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Apply Now',
                                style: kTitleTextStyle.copyWith(
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
