import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_listing_app/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailFooter extends StatelessWidget {
  const DetailFooter({super.key});

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
                      // ignore: deprecated_member_use
                      color: kAccentColor,
                      height: 20.sp,
                      width: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: kSpacingUnit * 2),
                Expanded(
                  child: Container(
                    height: kSpacingUnit * 6,
                    width: kSpacingUnit * 8,
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      borderRadius: BorderRadius.circular(kSpacingUnit * 3),
                    ),
                    child: Center(
                      child: Text(
                        'Apply Now',
                        style: kTitleTextStyle.copyWith(color: Colors.white),
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
