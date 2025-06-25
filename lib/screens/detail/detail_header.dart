import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_listing_app/constants.dart';
import 'package:job_listing_app/models/job.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.data});

  final Job data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit * 2,
        vertical: kSpacingUnit * 3,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 28.sp, color: Colors.black),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: CircleAvatar(
              radius: 40.w,
              backgroundColor: kAccentColor.withOpacity(0.1),
              backgroundImage: (data.companyLogoUrl.isNotEmpty &&
                      data.companyLogoUrl.startsWith('http'))
                  ? NetworkImage(data.companyLogoUrl)
                  : (data.imgUrl != null &&
                          data.imgUrl.isNotEmpty &&
                          data.imgUrl.startsWith('http'))
                      ? NetworkImage(data.imgUrl)
                      : null,
              child: (data.companyLogoUrl.isEmpty &&
                      (data.imgUrl == null ||
                          data.imgUrl.isEmpty ||
                          !data.imgUrl.startsWith('http')))
                  ? Icon(Icons.business, color: kAccentColor, size: 40.w)
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            data.companyName,
            style: kHeadingTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '${data.location}${data.type.isNotEmpty ? ', ${data.type}' : ''}',
            style: kSubTitleTextStyle.copyWith(color: kSecondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
