import 'package:flutter/material.dart';
import 'package:job_listing_app/constants.dart';
import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/screens/detail/detail_content.dart';
import 'package:job_listing_app/screens/detail/detail_footer.dart';
import 'package:job_listing_app/screens/detail/detail_header.dart';

class DetailScreen extends StatelessWidget {
  final Job data;

  const DetailScreen({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSilverColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                DetailHeader(key: UniqueKey(), data: data),
                DetailContent(key: UniqueKey(), data: data),
              ],
            ),
            DetailFooter(job: data),
          ],
        ),
      ),
    );
  }
}
