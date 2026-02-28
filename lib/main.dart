import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/api_repository.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DarazApp());
}

class DarazApp extends StatelessWidget {
  const DarazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ApiRepository(),
      child: BlocProvider(
        create: (ctx) => AuthBloc(ctx.read<ApiRepository>()),
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(
            title: 'Daraz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFFFF6B00),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const LoginScreen(),
          ),
        ),
      ),
    );
  }
}
