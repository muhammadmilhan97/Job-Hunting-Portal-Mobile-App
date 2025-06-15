import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, John!',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                'Find your dream job',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(Icons.person, size: 24.w, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
