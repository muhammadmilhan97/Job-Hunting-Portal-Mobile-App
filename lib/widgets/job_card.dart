import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_listing_app/constants.dart';
import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/screens/detail/detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/favorites_service.dart';

class JobCard extends StatefulWidget {
  final Job data;

  const JobCard({super.key, required this.data});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isFavorited = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user != null) {
      try {
        final isFavorited =
            await _favoritesService.isJobFavorited(user.uid, widget.data.docId);
        if (mounted) {
          setState(() {
            _isFavorited = isFavorited;
          });
        }
      } catch (e) {
        print('Error checking favorite status: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to favorite jobs.')),
      );
      return;
    }

    try {
      final newFavoriteStatus =
          await _favoritesService.toggleFavorite(user.uid, widget.data.docId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorites. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [kCardShadow]),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 500),
        openColor: kSilverColor,
        openElevation: 0,
        openBuilder: (context, action) {
          return DetailScreen(data: widget.data);
        },
        closedColor: Colors.transparent,
        closedElevation: 0,
        closedBuilder: (context, action) {
          return Container(
            // 🔥 Removed fixed height
            padding: EdgeInsets.all(kSpacingUnit * 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kSpacingUnit * 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Let column size naturally
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(widget.data.imgUrl,
                        height: 30.sp, width: 30.sp),
                    SizedBox(width: kSpacingUnit),
                    Expanded(
                      child: Text(
                        widget.data.companyName,
                        style: kCardTitleTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: SvgPicture.asset(
                        'assets/icons/heart_icon.svg',
                        height: 20.sp,
                        width: 20.sp,
                        colorFilter: ColorFilter.mode(
                          _isFavorited ? kAccentColor : kSecondaryTextColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kSpacingUnit),
                Text(widget.data.position, style: kSubTitleTextStyle),
                SizedBox(height: kSpacingUnit * 0.5),
                Text(widget.data.location, style: kCaptionTextStyle),
              ],
            ),
          );
        },
      ),
    );
  }
}
