// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'blocs/auth/auth_bloc.dart';
import 'repositories/api_repository.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiRepository>(
          create: (_) => ApiRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(ctx.read<ApiRepository>()),
          ),
        ],
        child: ScreenUtilInit(
          // Design size matching a standard mobile mockup.
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Daraz',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorSchemeSeed: const Color(0xFFFF6B00),
                useMaterial3: true,
                fontFamily: 'Roboto',
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              ),
              home: child,
            );
          },
          child: const LoginScreen(),
        ),
      ),
    );
  }
}
