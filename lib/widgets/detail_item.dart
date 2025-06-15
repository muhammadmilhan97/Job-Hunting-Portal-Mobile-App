import 'package:flutter/material.dart';
import 'package:job_listing_app/constants.dart';

class DetailItem extends StatelessWidget {
  final String value;

  const DetailItem({required Key key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: kSpacingUnit * 2),
      child: Text(
        value,
        style: kCaptionTextStyle.copyWith(
          color: kPrimaryTextColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
