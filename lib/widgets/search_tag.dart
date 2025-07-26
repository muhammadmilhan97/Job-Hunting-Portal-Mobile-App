import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_hunting_app_new/constants.dart';

class SearchTag extends StatelessWidget {
  final String tag;

  const SearchTag({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed fixed width and added padding
      margin: EdgeInsets.only(left: kSpacingUnit),
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit,
        vertical: kSpacingUnit * 0.6,
      ),
      decoration: BoxDecoration(
        color: kAccentColor,
        borderRadius: BorderRadius.circular(kSpacingUnit * 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // make row wrap its content
        children: [
          Text(tag, style: kCaptionTextStyle.copyWith(color: Colors.white)),
          SizedBox(width: kSpacingUnit),
          SvgPicture.asset(
            'assets/icons/close_icon.svg',
            height: 15.sp,
            width: 15.sp,
          ),
        ],
      ),
    );
  }
}
