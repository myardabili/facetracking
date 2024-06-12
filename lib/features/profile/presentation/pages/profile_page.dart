import 'package:facetracking/core/extensions/build_context_ext.dart';
import 'package:facetracking/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:facetracking/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/buttons.dart';
import '../../../../core/components/cicle_loading.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<LogoutBloc, LogoutState>(
          listener: (context, state) {
            if (state is LogoutFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is LogoutLoaded) {
              AuthLocalDatasource().removeAuthData();
              context.pushReplacement(const LoginPage());
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const LoginPage(),
              //     ));
            }
          },
          builder: (context, state) {
            if (state is LogoutLoading) {
              return const CircleLoading();
            }
            if (state is LogoutLoaded) {
              return Button.filled(
                onPressed: () {
                  context.read<LogoutBloc>().add(OnLogout());
                },
                label: 'Sign Out',
              );
            }
            return Button.filled(
              onPressed: () {
                context.read<LogoutBloc>().add(OnLogout());
              },
              label: 'Sign Out',
            );
          },
        ),
      ),
    );
  }
}
