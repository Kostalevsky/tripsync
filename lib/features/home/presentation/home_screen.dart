import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/auth/state/auth_controller.dart';
import 'package:tripsync/features/trips/presentation/widgets/trip_card.dart';
import 'package:tripsync/features/trips/presentation/widgets/trip_stat_chip.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final trips = ref.watch(tripsControllerProvider);

    final totalTravelers = trips.fold<int>(
      0,
      (sum, trip) => sum + trip.members.length,
    );

    final totalPlannedBudget = trips.fold<double>(
      0,
      (sum, trip) => sum + trip.totalBudget,
    );

    final totalPlaces = trips.fold<int>(
      0,
      (sum, trip) => sum + trip.votedPlacesCount,
    );

    return AppScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-trip');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новая поездка'),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Привет, ${user?.name ?? 'путешественник'} 👋',
                    style: AppTextStyles.displayLarge,
                  ).animate().fadeIn().slideX(begin: -0.05),
                ),
                IconButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Выйти',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Управляйте групповыми поездками, голосуйте за места, стройте план по дням и контролируйте бюджет.',
              style: AppTextStyles.bodyMedium,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.l),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Обзор TripSync', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      TripStatChip(
                        label: 'Поездки',
                        value: '${trips.length}',
                        icon: Icons.luggage_rounded,
                      ),
                      TripStatChip(
                        label: 'Участники',
                        value: '$totalTravelers',
                        icon: Icons.groups_rounded,
                      ),
                      TripStatChip(
                        label: 'Места',
                        value: '$totalPlaces',
                        icon: Icons.place_rounded,
                      ),
                      TripStatChip(
                        label: 'Бюджет',
                        value: '€${totalPlannedBudget.toStringAsFixed(0)}',
                        icon: Icons.pie_chart_outline_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.04),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Ваши поездки',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            ...List.generate(
              trips.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: TripCard(
                  trip: trips[index],
                  onTap: () {
                    context.push('/trip/${trips[index].id}');
                  },
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}