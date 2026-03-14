import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/features/auth/state/auth_controller.dart';
import 'package:tripsync/shared/state/app_bootstrap_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNext();
  }

  Future<void> _openNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final onboardingCompleted = ref.read(onboardingCompletedProvider);
    final authState = ref.read(authControllerProvider);

    if (!onboardingCompleted) {
      context.go('/onboarding');
      return;
    }

    if (!authState.isAuthenticated) {
      context.go('/login');
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(),

            const SizedBox(height: 20),

            Text(
              'TripSync',
              style: AppTextStyles.displayLarge,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 8),

            Text(
              'Планируйте поездки вместе',
              style: AppTextStyles.bodyMedium,
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }
}
