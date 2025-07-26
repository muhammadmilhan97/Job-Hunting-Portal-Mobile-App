import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_hunting_app_new/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/job.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';
import '../../services/favorites_service.dart';

class DetailFooter extends StatefulWidget {
  final Job job;
  const DetailFooter({super.key, required this.job});

  @override
  State<DetailFooter> createState() => _DetailFooterState();
}

class _DetailFooterState extends State<DetailFooter> {
  bool _isLoading = false;
  bool _isFavorited = false;
  bool _hasApplied = false;
  final FavoritesService _favoritesService = FavoritesService();
  final ApplicationService _applicationService = ApplicationService();

  @override
  void initState() {
    super.initState();
    _checkFavoriteAndApplicationStatus();
  }

  Future<void> _checkFavoriteAndApplicationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user != null) {
      try {
        final isFavorited =
            await _favoritesService.isJobFavorited(user.uid, widget.job.docId);
        final hasApplied = await _applicationService.hasUserApplied(
            user.uid, widget.job.docId);

        if (!mounted) return;
        setState(() {
          _isFavorited = isFavorited;
          _hasApplied = hasApplied;
        });
      } catch (e) {
        // print('Error checking status: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to favorite jobs.')),
      );
      return;
    }

    try {
      final newFavoriteStatus =
          await _favoritesService.toggleFavorite(user.uid, widget.job.docId);
      if (!mounted) return;
      setState(() {
        _isFavorited = newFavoriteStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorited ? 'Added to favorites!' : 'Removed from favorites!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorites. Please try again.')),
      );
    }
  }

  Future<void> _applyForJob(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to apply.')),
      );
      return;
    }

    // Check if user has already applied
    if (_hasApplied) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already applied for this job.')),
      );
      return;
    }

    final cvUrl = user.profileData['cvUrl'];
    if (cvUrl.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please complete your profile and upload your CV before applying.')),
      );
      return;
    }
    if (widget.job.docId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Job information is missing. Please try again later.')),
      );
      return;
    }
    final expectedSalary = user.expectedSalary ?? '';
    final experience = user.experience ?? '';
    final employerId = widget.job.postedBy;
    final userName = user.name;
    final jobTitle = widget.job.position;
    setState(() => _isLoading = true);

    try {
      await _applicationService.submitApplication(
        jobId: widget.job.docId,
        userId: user.uid,
        cvUrl: cvUrl,
        expectedSalary: expectedSalary,
        experience: experience,
        employerId: employerId,
        userName: userName,
        jobTitle: jobTitle,
        userEmail: user.email,
        companyName: widget.job.companyName,
      );
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      setState(() => _hasApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit application. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(),
        Container(
          margin: EdgeInsets.only(
            left: kSpacingUnit * 2,
            right: kSpacingUnit * 2,
            bottom: kSpacingUnit * 2,
          ),
          child: Container(
            padding: EdgeInsets.all(kSpacingUnit * 2),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [kFooterShadow],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    height: kSpacingUnit * 6,
                    width: kSpacingUnit * 8,
                    decoration: BoxDecoration(
                      color: kSilverColor,
                      borderRadius: BorderRadius.circular(kSpacingUnit * 3),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/heart_icon.svg',
                        colorFilter: ColorFilter.mode(
                            _isFavorited ? kAccentColor : kSecondaryTextColor,
                            BlendMode.srcIn),
                        height: 20.sp,
                        width: 20.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: kSpacingUnit * 2),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isLoading) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please wait...')),
                        );
                        return;
                      }
                      if (_hasApplied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'You have already applied for this job.')),
                        );
                        return;
                      }
                      _applyForJob(context);
                    },
                    child: Container(
                      height: kSpacingUnit * 6,
                      width: kSpacingUnit * 8,
                      decoration: BoxDecoration(
                        color: _hasApplied || _isLoading
                            ? Colors.grey
                            : kAccentColor,
                        borderRadius: BorderRadius.circular(kSpacingUnit * 3),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _hasApplied ? 'Already Applied' : 'Apply Now',
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
