import 'package:facetracking/core/extensions/build_context_ext.dart';
import 'package:facetracking/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/components/spaces.dart';
import '../../../../core/constants/colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 2),
      () => context.pushReplacement(const LoginPage()),
    );
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Assets.images.logoWhite.image(),
          ),
          const Spacer(),
          Assets.images.logoCodeWithBahri.image(height: 70),
          const SpaceHeight(20.0),
        ],
      ),
    );
  }
}
