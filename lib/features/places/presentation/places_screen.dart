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
import 'package:tripsync/features/places/state/places_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final placesState = ref.watch(placesControllerProvider);
    final places = [...(placesState[tripId] ?? const [])]..sort((a, b) => b.votes.compareTo(a.votes));

    if (trip == null) {
      return const Scaffold(
        body: Center(child: Text('Поездка не найдена')),
      );
    }

    return AppScaffold(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              title: 'Голосование за места',
              onBack: () => context.pop(),
            ),
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
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Участники предлагают локации, а список автоматически сортируется по количеству голосов.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: AppSpacing.l),
            ...List.generate(
              places.length,
              (index) {
                final place = places[index];
                final hasVoted = user != null && place.votedBy.contains(user.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(place.emoji, style: const TextStyle(fontSize: 30)),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(place.title, style: AppTextStyles.titleLarge),
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.m,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.round),
                                    ),
                                    child: Text(
                                      place.category,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.m,
                                vertical: AppSpacing.s,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.round),
                              ),
                              child: Text(
                                '${place.votes} голосов',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          place.description,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: user == null
                                    ? null
                                    : () {
                                        ref
                                            .read(placesControllerProvider.notifier)
                                            .toggleVote(
                                              tripId: tripId,
                                              placeId: place.id,
                                              userId: user.id,
                                            );
                                      },
                                icon: Icon(
                                  hasVoted
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                                label: Text(
                                  hasVoted ? 'Убрать голос' : 'Проголосовать',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.05),
                );
              },
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircleButton(
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.round),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.round),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.round),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}