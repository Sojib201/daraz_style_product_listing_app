import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product.dart';

class ProductSliverGrid extends StatelessWidget {
  final List<Product> products;
  const ProductSliverGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _ProductCard(product: products[i]),
          childCount: products.length,
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

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade50,
                      child: Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'BDT ${(product.price * 110).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber.shade600, size: 12.sp),
                      SizedBox(width: 2.w),
                      Text(
                        product.rating.rate.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '  |  ${product.rating.count} sold',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
