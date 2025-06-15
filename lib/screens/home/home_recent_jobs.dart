import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeRecentJobs extends StatelessWidget {
  const HomeRecentJobs({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data later
    return Column(
      children: [
        _buildJobCard(
          'Software Engineer',
          'Google',
          'Mountain View, CA',
          '\$120k - \$150k',
          'Full-time',
        ),
        _buildJobCard(
          'Product Designer',
          'Apple',
          'Cupertino, CA',
          '\$100k - \$130k',
          'Full-time',
        ),
        _buildJobCard(
          'Data Scientist',
          'Microsoft',
          'Redmond, WA',
          '\$110k - \$140k',
          'Full-time',
        ),
      ],
    );
  }

  Widget _buildJobCard(
    String title,
    String company,
    String location,
    String salary,
    String type,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              color: Colors.blue.withOpacity(0.1),
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
