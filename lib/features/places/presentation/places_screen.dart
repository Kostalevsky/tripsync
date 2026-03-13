import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/auth/state/auth_controller.dart';
import 'package:tripsync/features/places/domain/place_suggestion.dart';
import 'package:tripsync/features/places/state/places_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  void _showPlaceSheet(
    BuildContext context,
    WidgetRef ref,
    String tripId, {
    PlaceSuggestion? place,
  }) {
    final isEditing = place != null;

    final titleController = TextEditingController(text: place?.title ?? '');
    final categoryController =
        TextEditingController(text: place?.category ?? '');
    final descriptionController =
        TextEditingController(text: place?.description ?? '');
    final emojiController = TextEditingController(text: place?.emoji ?? '📍');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
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
                      isEditing ? 'Редактировать место' : 'Добавить место',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Например: Эрмитаж',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        hintText: 'Музей / Еда / Парк / Активность',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        hintText: 'Коротко опишите, почему это место стоит посетить',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: emojiController,
                      decoration: const InputDecoration(
                        labelText: 'Эмодзи',
                        hintText: 'Например: 🏛️',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final category = categoryController.text.trim();
                          final description = descriptionController.text.trim();
                          final emoji = emojiController.text.trim();

                          if (title.isEmpty ||
                              category.isEmpty ||
                              description.isEmpty ||
                              emoji.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Заполните все поля'),
                              ),
                            );
                            return;
                          }

                          final currentUser =
                              ref.read(authControllerProvider).user;

                          final nextPlace = PlaceSuggestion(
                            id: place?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            title: title,
                            category: category,
                            description: description,
                            emoji: emoji,
                            votes: place?.votes ?? 0,
                            votedBy: place?.votedBy ?? const [],
                          );

                          if (isEditing) {
                            ref
                                .read(placesControllerProvider.notifier)
                                .updatePlace(
                                  tripId: tripId,
                                  updatedPlace: nextPlace,
                                );
                          } else {
                            ref
                                .read(placesControllerProvider.notifier)
                                .addPlace(
                                  tripId: tripId,
                                  place: nextPlace,
                                );
                          }

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Место обновлено'
                                    : 'Место добавлено',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isEditing ? Icons.save_rounded : Icons.add_rounded,
                        ),
                        label: Text(
                          isEditing ? 'Сохранить' : 'Добавить',
                        ),
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

  Future<void> _confirmDeletePlace(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    PlaceSuggestion place,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить место?'),
              content: Text(
                'Место "${place.title}" будет удалено из списка.',
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

    ref.read(placesControllerProvider.notifier).deletePlace(
          tripId: tripId,
          placeId: place.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Место удалено'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final placesState = ref.watch(placesControllerProvider);
    final places = [...(placesState[tripId] ?? const <PlaceSuggestion>[])]
      ..sort((a, b) => b.votes.compareTo(a.votes));

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
              onAdd: () => _showPlaceSheet(context, ref, tripId),
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
                    'Участники предлагают локации, голосуют за них, а список автоматически сортируется по количеству голосов.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (places.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📍',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Пока нет предложенных мест',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Добавьте первое место для голосования.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    FilledButton.icon(
                      onPressed: () => _showPlaceSheet(context, ref, tripId),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Добавить место'),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                places.length,
                (index) {
                  final place = places[index];
                  final hasVoted = user != null && place.votedBy.contains(user.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.l),
                    child: InkWell(
                      onTap: () => _showPlaceSheet(
                        context,
                        ref,
                        tripId,
                        place: place,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
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
                                Text(
                                  place.emoji,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.title,
                                        style: AppTextStyles.titleLarge,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.m,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.round,
                                          ),
                                        ),
                                        child: Text(
                                          place.category,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.m,
                                        vertical: AppSpacing.s,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.round,
                                        ),
                                      ),
                                      child: Text(
                                        '${place.votes} голосов',
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _showPlaceSheet(
                                            context,
                                            ref,
                                            tripId,
                                            place: place,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.round,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadii.round,
                                              ),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.s),
                                        InkWell(
                                          onTap: () => _confirmDeletePlace(
                                            context,
                                            ref,
                                            tripId,
                                            place,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.round,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadii.round,
                                              ),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.error,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                                .read(
                                                  placesControllerProvider
                                                      .notifier,
                                                )
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
                                      hasVoted
                                          ? 'Убрать голос'
                                          : 'Проголосовать',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
    required this.onAdd,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onAdd;

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
        const SizedBox(width: AppSpacing.s),
        _IconCircleButton(
          icon: Icons.add_rounded,
          onPressed: onAdd,
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