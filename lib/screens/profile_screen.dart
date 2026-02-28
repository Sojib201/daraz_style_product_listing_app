import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return _ProfileBody(user: state.user);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            actions: [
              TextButton.icon(
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const AuthLogoutRequested()),
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: const Text('Logout',
                    style:
                        TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32.sp,
                          color: const Color(0xFFFF6B00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _InfoCard(
                    title: 'Contact',
                    rows: [
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: user.phone),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    title: 'Delivery Address',
                    rows: [
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: user.address.full,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    title: 'Account',
                    rows: [
                      _InfoRow(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                        value: 'View all orders',
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.grey),
                      ),
                      _InfoRow(
                        icon: Icons.favorite_outline,
                        label: 'Wishlist',
                        value: 'Saved items',
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.grey),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...rows.expand((r) => [
                r,
                if (rows.last != r)
                  Divider(
                      height: 1,
                      indent: 48.w,
                      color: Colors.grey.shade100),
              ]),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon,
                size: 16.sp, color: const Color(0xFFFF6B00)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade500)),
                SizedBox(height: 1.h),
                Text(value,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
