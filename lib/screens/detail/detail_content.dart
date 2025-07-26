import 'package:flutter/material.dart';
import 'package:job_hunting_app_new/constants.dart';
import 'package:job_hunting_app_new/models/job.dart';

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
              Text('Responsibilities', style: kSubTitleTextStyle),
              SizedBox(height: kSpacingUnit * 2),
              if (data.responsibilities.isNotEmpty)
                (data.responsibilities.length == 1)
                    ? Text(data.responsibilities.first, style: kBodyTextStyle)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.responsibilities
                            .asMap()
                            .entries
                            .map(
                              (entry) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ', style: kBodyTextStyle),
                                  Expanded(
                                      child: Text(entry.value,
                                          style: kBodyTextStyle)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
              SizedBox(height: kSpacingUnit),
              Text('Qualifications', style: kSubTitleTextStyle),
              SizedBox(height: kSpacingUnit * 2),
              if (data.qualifications.isNotEmpty)
                (data.qualifications.length == 1)
                    ? Text(data.qualifications.first, style: kBodyTextStyle)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.qualifications
                            .asMap()
                            .entries
                            .map(
                              (entry) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ', style: kBodyTextStyle),
                                  Expanded(
                                      child: Text(entry.value,
                                          style: kBodyTextStyle)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
              SizedBox(height: kSpacingUnit * 15),
            ],
          ),
        ),
      ),
    );
  }
}
