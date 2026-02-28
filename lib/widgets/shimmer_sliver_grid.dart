import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSliverGrid extends StatelessWidget {
  const ShimmerSliverGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          childCount: 8,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.66,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
      ),
    );
  }
}
