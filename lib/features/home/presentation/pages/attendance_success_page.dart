// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:facetracking/core/assets/assets.gen.dart';
import 'package:facetracking/core/components/components.dart';
import 'package:facetracking/core/constants/colors.dart';
import 'package:facetracking/core/extensions/build_context_ext.dart';
import 'package:flutter/material.dart';

class AttendanceSuccessPage extends StatelessWidget {
  final String status;
  const AttendanceSuccessPage({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.success.image(),
            const Text(
              'Asiap!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SpaceHeight(8),
            Center(
              child: Text(
                'Anda telah berhasil melakukan absensi $status pada pukul ${DateTime.now()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.grey,
                ),
              ),
            ),
            const SpaceHeight(80),
            Button.filled(
              onPressed: () => context.popToRoot(),
              label: 'Oke, dimengerti',
            ),
          ],
        ),
      ),
    );
  }
}
