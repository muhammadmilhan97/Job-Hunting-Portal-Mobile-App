import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_listing_app/constants.dart';
import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/screens/detail/detail_screen.dart';

class JobCard extends StatelessWidget {
  final Job data;

  const JobCard({super.key, required this.data});

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
          return DetailScreen(data: data);
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
                    SvgPicture.asset(data.imgUrl, height: 30.sp, width: 30.sp),
                    SizedBox(width: kSpacingUnit),
                    Expanded(
                      child: Text(
                        data.companyName,
                        style: kCardTitleTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/heart_icon.svg',
                      height: 20.sp,
                      width: 20.sp,
                    ),
                  ],
                ),
                SizedBox(height: kSpacingUnit),
                Text(data.position, style: kSubTitleTextStyle),
                SizedBox(height: kSpacingUnit * 0.5),
                Text(data.location, style: kCaptionTextStyle),
              ],
            ),
          );
        },
      ),
    );
  }
}
