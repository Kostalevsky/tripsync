import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/planner/domain/planned_activity.dart';
import 'package:tripsync/features/planner/state/planner_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key, required this.tripId});

  final String tripId;

  void _showAddDaySheet(BuildContext context, WidgetRef ref, String tripId) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadii.round),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('Добавить день', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Название дня',
                        hintText: 'Например: 20 июл, День прилёта, Суббота',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final title = controller.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Введите название дня'),
                              ),
                            );
                            return;
                          }

                          ref
                              .read(plannerControllerProvider.notifier)
                              .addDay(tripId: tripId, dayTitle: title);

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('День добавлен')),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Добавить день'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActivitySheet(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    String dayKey, {
    PlannedActivity? activity,
  }) {
    final isEditing = activity != null;

    final titleController = TextEditingController(text: activity?.title ?? '');
    final locationController = TextEditingController(
      text: activity?.location ?? '',
    );
    final timeController = TextEditingController(
      text: activity?.startTime ?? '',
    );
    final emojiController = TextEditingController(
      text: activity?.emoji ?? '📍',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadii.round),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      isEditing
                          ? 'Редактировать активность'
                          : 'Добавить активность',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Например: Ужин, музей, прогулка',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Локация',
                        hintText: 'Например: Центр города',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Время',
                        hintText: 'Например: 14:30',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: emojiController,
                      decoration: const InputDecoration(
                        labelText: 'Эмодзи',
                        hintText: 'Например: 🍽️',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final location = locationController.text.trim();
                          final startTime = timeController.text.trim();
                          final emoji = emojiController.text.trim();

                          if (title.isEmpty ||
                              location.isEmpty ||
                              startTime.isEmpty ||
                              emoji.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Заполните все поля'),
                              ),
                            );
                            return;
                          }

                          final nextActivity = PlannedActivity(
                            id:
                                activity?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            title: title,
                            location: location,
                            startTime: startTime,
                            durationMinutes: activity?.durationMinutes ?? 60,
                            emoji: emoji,
                          );

                          if (isEditing) {
                            ref
                                .read(plannerControllerProvider.notifier)
                                .updateActivity(
                                  tripId: tripId,
                                  dayKey: dayKey,
                                  updated: nextActivity,
                                );
                          } else {
                            ref
                                .read(plannerControllerProvider.notifier)
                                .addActivity(
                                  tripId: tripId,
                                  dayKey: dayKey,
                                  activity: nextActivity,
                                );
                          }

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Активность обновлена'
                                    : 'Активность добавлена',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isEditing ? Icons.save_rounded : Icons.add_rounded,
                        ),
                        label: Text(isEditing ? 'Сохранить' : 'Добавить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteActivity(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    String dayKey,
    PlannedActivity activity,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить активность?'),
              content: Text(
                'Активность "${activity.title}" будет удалена из плана.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    ref
        .read(plannerControllerProvider.notifier)
        .deleteActivity(
          tripId: tripId,
          dayKey: dayKey,
          activityId: activity.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Активность удалена')));
  }

  Future<void> _confirmDeleteDay(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    String dayKey,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить день?'),
              content: Text(
                'День "$dayKey" будет удалён вместе со всеми активностями.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    ref
        .read(plannerControllerProvider.notifier)
        .deleteDay(tripId: tripId, dayKey: dayKey);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('День удалён')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    // ref.read(plannerControllerProvider.notifier).ensureTripExists(tripId);
    final days = ref.watch(plannerControllerProvider)[tripId] ?? {};

    if (trip == null) {
      return const Scaffold(body: Center(child: Text('Поездка не найдена')));
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
              onAddDay: () => _showAddDaySheet(context, ref, tripId),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Создавайте дни поездки, наполняйте их активностями и меняйте порядок внутри дня.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            if (days.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text('🗓️', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Пока нет дней в планировщике',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Добавьте первый день поездки и начните собирать маршрут.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    FilledButton.icon(
                      onPressed: () => _showAddDaySheet(context, ref, tripId),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Добавить день'),
                    ),
                  ],
                ),
              )
            else
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: AppTextStyles.titleLarge,
                              ),
                            ),
                            _SmallActionButton(
                              icon: Icons.add_rounded,
                              onPressed: () {
                                _showActivitySheet(
                                  context,
                                  ref,
                                  tripId,
                                  entry.key,
                                );
                              },
                            ),
                            const SizedBox(width: AppSpacing.s),
                            _SmallActionButton(
                              icon: Icons.delete_outline_rounded,
                              iconColor: AppColors.error,
                              onPressed: () {
                                _confirmDeleteDay(
                                  context,
                                  ref,
                                  tripId,
                                  entry.key,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        if (entry.value.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.l),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadii.l),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '📍',
                                  style: TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Text(
                                  'Пока нет активностей',
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Добавьте первую активность в этот день.',
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            buildDefaultDragHandles: false,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entry.value.length,
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(plannerControllerProvider.notifier)
                                  .reorderActivities(
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
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.m,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.m),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.l,
                                  ),
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
                                      child: InkWell(
                                        onTap: () {
                                          _showActivitySheet(
                                            context,
                                            ref,
                                            tripId,
                                            entry.key,
                                            activity: activity,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.l,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activity.title,
                                              style: AppTextStyles.titleMedium,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              '${activity.startTime} • ${activity.location}',
                                              style: AppTextStyles.bodySmall,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.s,
                                            ),
                                            Row(
                                              children: [
                                                _DurationButton(
                                                  icon: Icons.remove_rounded,
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          plannerControllerProvider
                                                              .notifier,
                                                        )
                                                        .decreaseDuration(
                                                          tripId: tripId,
                                                          dayKey: entry.key,
                                                          activityId:
                                                              activity.id,
                                                        );
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.s,
                                                ),
                                                Text(
                                                  '${activity.durationMinutes} мин',
                                                  style:
                                                      AppTextStyles.titleMedium,
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.s,
                                                ),
                                                _DurationButton(
                                                  icon: Icons.add_rounded,
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          plannerControllerProvider
                                                              .notifier,
                                                        )
                                                        .increaseDuration(
                                                          tripId: tripId,
                                                          dayKey: entry.key,
                                                          activityId:
                                                              activity.id,
                                                        );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s),
                                    Column(
                                      children: [
                                        _SmallActionButton(
                                          icon: Icons.edit_outlined,
                                          iconColor: AppColors.primary,
                                          onPressed: () {
                                            _showActivitySheet(
                                              context,
                                              ref,
                                              tripId,
                                              entry.key,
                                              activity: activity,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: AppSpacing.s),
                                        _SmallActionButton(
                                          icon: Icons.delete_outline_rounded,
                                          iconColor: AppColors.error,
                                          onPressed: () {
                                            _confirmDeleteActivity(
                                              context,
                                              ref,
                                              tripId,
                                              entry.key,
                                              activity,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: AppSpacing.s),
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(
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
    required this.onAddDay,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onAddDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircleButton(icon: Icons.arrow_back_rounded, onPressed: onBack),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: Text(title, style: AppTextStyles.headlineLarge)),
        const SizedBox(width: AppSpacing.s),
        _IconCircleButton(icon: Icons.add_rounded, onPressed: onAddDay),
      ],
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({required this.icon, required this.onPressed});

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
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadii.round),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.round),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onPressed});

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
