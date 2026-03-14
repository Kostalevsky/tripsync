import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/features/trips/domain/trip.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  LinearGradient _gradientForSeed(int seed) {
    switch (seed % 3) {
      case 0:
        return const LinearGradient(
          colors: [Color(0xFF5B8CFF), Color(0xFF8E7CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFFFC371)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF5EEAD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          gradient: _gradientForSeed(trip.colorSeed),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'trip_emoji_${trip.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      trip.coverEmoji,
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.round),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Открыть',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              trip.title,
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              trip.destination,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              trip.dateRange,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                ...trip.members
                    .take(4)
                    .map(
                      (member) => Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          member.avatar,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                const Spacer(),
                Text(
                  '${trip.members.length} участников',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.round),
              child: LinearProgressIndicator(
                value: trip.budgetProgress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Использовано: ₽${trip.spentBudget.toStringAsFixed(0)} / ₽${trip.totalBudget.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08),
    );
  }
}
