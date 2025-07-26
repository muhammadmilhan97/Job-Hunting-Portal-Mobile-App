import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePopularJobs extends StatelessWidget {
  const HomePopularJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPopularJobCard(
            'Senior Developer',
            'Amazon',
            'Seattle, WA',
            '\$130k - \$160k',
            'Full-time',
          ),
          _buildPopularJobCard(
            'UX Designer',
            'Facebook',
            'Menlo Park, CA',
            '\$90k - \$120k',
            'Full-time',
          ),
          _buildPopularJobCard(
            'DevOps Engineer',
            'Netflix',
            'Los Gatos, CA',
            '\$140k - \$170k',
            'Full-time',
          ),
        ],
      ),
    );
  }

  Widget _buildPopularJobCard(
    String title,
    String company,
    String location,
    String salary,
    String type,
  ) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(left: 20.w, right: 8.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(company, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on, size: 16.w, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                location,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.attach_money, size: 16.w, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                salary,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(25),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
