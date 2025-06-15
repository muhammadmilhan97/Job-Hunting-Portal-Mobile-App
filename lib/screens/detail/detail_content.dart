import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_listing_app/constants.dart';
import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/widgets/detail_item.dart';

class DetailContent extends StatelessWidget {
  final Job data;

  const DetailContent({required Key key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: kSpacingUnit * 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kSpacingUnit * 5),
            topRight: Radius.circular(kSpacingUnit * 5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: kSpacingUnit * 5),
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(data.imgUrl, height: 50.sp, width: 50.sp),
                    SizedBox(height: kSpacingUnit * 2),
                    Text(data.companyName, style: kTitleTextStyle),
                    SizedBox(height: kSpacingUnit),
                    Text(data.location, style: kCaptionTextStyle),
                  ],
                ),
              ),
              SizedBox(height: kSpacingUnit * 5),
              Text('Responsibilities', style: kSubTitleTextStyle),
              SizedBox(height: kSpacingUnit * 2),
              if (data.responsibilities.isNotEmpty)
                ...data.responsibilities.asMap().entries.map(
                  (entry) => DetailItem(
                    key: ValueKey('res-${entry.key}'),
                    value: entry.value,
                  ),
                ),
              SizedBox(height: kSpacingUnit),
              Text('Qualifications', style: kSubTitleTextStyle),
              SizedBox(height: kSpacingUnit * 2),
              if (data.qualifications.isNotEmpty)
                ...data.qualifications.asMap().entries.map(
                  (entry) => DetailItem(
                    key: ValueKey('qual-${entry.key}'),
                    value: entry.value,
                  ),
                ),
              SizedBox(height: kSpacingUnit * 15),
            ],
          ),
        ),
      ),
    );
  }
}
