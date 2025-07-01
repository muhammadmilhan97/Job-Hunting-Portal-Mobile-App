import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final kSpacingUnit = 10.00.w;

const kSilverColor = Color(0xFFF6F7FB);
const kAccentColor = Color(0xFFED5575);
const kPrimaryTextColor = Color(0xFF211D42);
const kSecondaryTextColor = Color(0xFFB9B8CD);

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
}

final kCardShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.05),
  blurRadius: 20.w,
  offset: Offset(10.w, 10.w),
);

final kFooterShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.10),
  blurRadius: 50.w,
  offset: Offset(0, -10.w),
);

final kHeadingTextStyle = TextStyle(
  color: kPrimaryTextColor,
  fontFamily: 'SF Pro Rounded',
  fontSize: 34.sp,
  fontWeight: FontWeight.w100,
);

final kTitleTextStyle = TextStyle(
  color: kPrimaryTextColor,
  fontSize: 17.sp,
  fontWeight: FontWeight.w500,
);

final kSubTitleTextStyle = TextStyle(
  color: kPrimaryTextColor,
  fontSize: 15.sp,
  fontWeight: FontWeight.w500,
);

final kCardTitleTextStyle = TextStyle(
  color: kSecondaryTextColor,
  fontSize: 13.sp,
  fontWeight: FontWeight.w500,
);

final kBodyTextStyle = TextStyle(color: kPrimaryTextColor, fontSize: 13.sp);

final kCaptionTextStyle = TextStyle(
  color: kSecondaryTextColor,
  fontSize: 10.sp,
);
