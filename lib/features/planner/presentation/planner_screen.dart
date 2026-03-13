import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/planner/state/planner_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final days = ref.watch(plannerControllerProvider)[tripId] ?? {};

    if (trip == null) {
      return const Scaffold(
        body: Center(
          child: Text('Поездка не найдена'),
        ),
      );
    }

    return AppScaffold(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              title: 'Планировщик',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Перетаскивайте активности внутри дня и меняйте длительность.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            ...days.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(plannerControllerProvider.notifier).reorderActivities(
                                tripId: tripId,
                                dayKey: entry.key,
                                oldIndex: oldIndex,
                                newIndex: newIndex,
                              );
                        },
                        itemBuilder: (context, index) {
                          final activity = entry.value[index];

                          return Container(
                            key: ValueKey(activity.id),
                            margin: const EdgeInsets.only(bottom: AppSpacing.m),
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadii.l),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.round,
                                    ),
                                    border: Border.all(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    activity.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.title,
                                        style: AppTextStyles.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${activity.startTime} • ${activity.location}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const SizedBox(height: AppSpacing.s),
                                      Row(
                                        children: [
                                          _DurationButton(
                                            icon: Icons.remove_rounded,
                                            onPressed: () {
                                              ref
                                                  .read(plannerControllerProvider.notifier)
                                                  .decreaseDuration(
                                                    tripId: tripId,
                                                    dayKey: entry.key,
                                                    activityId: activity.id,
                                                  );
                                            },
                                          ),
                                          const SizedBox(width: AppSpacing.s),
                                          Text(
                                            '${activity.durationMinutes} мин',
                                            style: AppTextStyles.titleMedium,
                                          ),
                                          const SizedBox(width: AppSpacing.s),
                                          _DurationButton(
                                            icon: Icons.add_rounded,
                                            onPressed: () {
                                              ref
                                                  .read(plannerControllerProvider.notifier)
                                                  .increaseDuration(
                                                    tripId: tripId,
                                                    dayKey: entry.key,
                                                    activityId: activity.id,
                                                  );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.round,
                                      ),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.drag_handle_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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

class _DurationButton extends StatelessWidget {
  const _DurationButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadii.round),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.round),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
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
          child: Icon(
            icon,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}