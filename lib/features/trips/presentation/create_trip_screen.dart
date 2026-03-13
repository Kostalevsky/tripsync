import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/core/widgets/primary_button.dart';
import 'package:tripsync/features/auth/state/auth_controller.dart';
import 'package:tripsync/features/trips/domain/trip.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateRangeController = TextEditingController();
  final _budgetController = TextEditingController(text: '2000');
  final _membersController = TextEditingController(text: 'Анна, Лео, Мия');

  String _selectedEmoji = '✈️';

  final _emojiOptions = const ['✈️', '🏝️', '🌆', '🏔️', '🎡', '🌍', '🚄', '🏕️'];

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _dateRangeController.dispose();
    _budgetController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  void _createTrip() {
    if (!_formKey.currentState!.validate()) return;

    final authUser = ref.read(authControllerProvider).user;

    final enteredMembers = _membersController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final tripMembers = <TripMember>[
      TripMember(
        id: authUser?.id ?? 'me',
        name: authUser?.name ?? 'Я',
        avatar: authUser?.avatar ?? '🧑',
      ),
      ...enteredMembers.asMap().entries.map(
            (entry) => TripMember(
              id: 'new_${entry.key}',
              name: entry.value,
              avatar: _memberAvatarForIndex(entry.key),
            ),
          ),
    ];

    final trip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      destination: _destinationController.text.trim(),
      dateRange: _dateRangeController.text.trim(),
      coverEmoji: _selectedEmoji,
      members: tripMembers,
      totalBudget: double.tryParse(_budgetController.text.trim()) ?? 2000,
      spentBudget: 0,
      votedPlacesCount: 0,
      plannedActivitiesCount: 0,
      colorSeed: Random().nextInt(3),
    );

    ref.read(tripsControllerProvider.notifier).addTrip(trip);

    context.go('/trip/${trip.id}');
  }

  String _memberAvatarForIndex(int index) {
    const avatars = ['👩🏻', '🧔🏼', '👩🏾', '🧑🏻', '👱🏻‍♀️', '🧑🏾', '👩🏻‍🦰'];
    return avatars[index % avatars.length];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Создать поездку',
                      style: AppTextStyles.headlineLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Добавьте основные данные о поездке. После создания она сразу появится в приложении.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Основная информация', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название поездки',
                        hintText: 'Например: Лиссабон с друзьями',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите название поездки';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Направление',
                        hintText: 'Например: Лиссабон, Португалия',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите направление';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _dateRangeController,
                      decoration: const InputDecoration(
                        labelText: 'Даты',
                        hintText: 'Например: 20–26 июл 2026',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите даты поездки';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Общий бюджет (€)',
                        hintText: 'Например: 2500',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите бюджет';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Введите число';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Участники и стиль', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _membersController,
                      decoration: const InputDecoration(
                        labelText: 'Участники',
                        hintText: 'Через запятую: Анна, Лео, Мия',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text('Обложка поездки', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.m),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _emojiOptions.map((emoji) {
                        final isSelected = emoji == _selectedEmoji;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                            });
                          },
                          borderRadius: BorderRadius.circular(AppRadii.round),
                          child: Container(
                            width: 54,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadii.round),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Создать поездку',
                onPressed: _createTrip,
                icon: const Icon(Icons.check_rounded),
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
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