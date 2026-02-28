import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/auth/auth_bloc.dart';
import 'product_listing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'mor_2314');
  final _passwordCtrl = TextEditingController(text: '83r5^_');
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ProductListingScreen()),
          );
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFF6B00),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'daraz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 54.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'It\'s all here',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 16.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sign In',
                              style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 4.h),
                          Text('Demo credentials pre-filled',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey)),
                          SizedBox(height: 24.h),

                          _FormField(
                            controller: _usernameCtrl,
                            label: 'Username',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter username'
                                : null,
                          ),
                          SizedBox(height: 14.h),

                          _FormField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter password'
                                : null,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20.sp,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading;
                              return SizedBox(
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFFFF6B00).withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    elevation: 0,
                                  ),
                                  child: loading
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Sign In',
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 20.sp),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
