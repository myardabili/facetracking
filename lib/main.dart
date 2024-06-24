import 'package:facetracking/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:facetracking/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:facetracking/features/auth/presentation/pages/splash_page.dart';
import 'package:facetracking/features/home/data/datasources/attendance_remote_datasource.dart';
import 'package:facetracking/features/home/presentation/bloc/checkin/checkin_bloc.dart';
import 'package:facetracking/features/home/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:facetracking/features/home/presentation/bloc/company/company_bloc.dart';
import 'package:facetracking/features/home/presentation/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:facetracking/features/home/presentation/bloc/register_face/register_face_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/bloc/login/login_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => RegisterFaceBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CompanyBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CheckinBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CheckoutBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => IsCheckedinBloc(AttendanceRemoteDatasource()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}
