import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/trips/domain/trip.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final String tripId;

  String _buildInviteLink(Trip trip) {
    return 'https://tripsync.app/invite/${trip.id}';
  }

  String _buildInviteCode(Trip trip) {
    final normalized = trip.id
        .replaceAll('trip_', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();

    final short = normalized.length >= 6
        ? normalized.substring(0, 6)
        : normalized.padRight(6, 'X');

    return 'TS-$short';
  }

  Future<void> _confirmDeleteTrip(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить поездку?'),
              content: Text(
                'Поездка "${trip.title}" будет удалена из списка. Это действие нельзя отменить.',
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

    if (!shouldDelete || !context.mounted) return;

    ref.read(tripsControllerProvider.notifier).deleteTrip(trip.id);

    if (!context.mounted) return;

    context.go('/home');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Поездка "${trip.title}" удалена')));
  }

  void _showShareSheet(BuildContext context, Trip trip) {
    final inviteLink = _buildInviteLink(trip);
    final inviteCode = _buildInviteCode(trip);

    final shareText =
        '''
Присоединяйся к моей поездке в TripSync!

Поездка: ${trip.title}
Направление: ${trip.destination}
Даты: ${trip.dateRange}

Код приглашения: $inviteCode
Ссылка: $inviteLink
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadii.round),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadii.l),
                          ),
                          child: Text(
                            trip.coverEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Приглашение в поездку',
                                style: AppTextStyles.headlineLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(trip.title, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B8CFF), Color(0xFF8E7CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Поделитесь поездкой с друзьями',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Участники смогут быстро открыть поездку по ссылке или ввести короткий код приглашения.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Row(
                            children: [
                              Expanded(
                                child: _InviteStatCard(
                                  label: 'Участников',
                                  value: '${trip.members.length}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: _InviteStatCard(
                                  label: 'Мест',
                                  value: '${trip.votedPlacesCount}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: _InviteStatCard(
                                  label: 'Активностей',
                                  value: '${trip.plannedActivitiesCount}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('Код приглашения', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.s),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.l,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              inviteCode,
                              style: AppTextStyles.displayMedium.copyWith(
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: inviteCode),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Код приглашения скопирован'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('Копировать'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('Ссылка-приглашение', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.s),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SelectableText(
                        inviteLink,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Что увидят участники',
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          const _InfoRow(
                            icon: Icons.groups_rounded,
                            text: 'Состав группы и детали поездки',
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const _InfoRow(
                            icon: Icons.how_to_vote_rounded,
                            text: 'Голосование за места и идеи маршрута',
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const _InfoRow(
                            icon: Icons.timeline_rounded,
                            text: 'Планировщик активностей по дням',
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const _InfoRow(
                            icon: Icons.account_balance_wallet_rounded,
                            text: 'Бюджет и взаиморасчёты',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: inviteLink),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ссылка скопирована'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.link_rounded),
                            label: const Text('Скопировать ссылку'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Share.share(shareText);
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Поделиться поездкой'),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tripsControllerProvider.notifier);
    final trip = controller.getById(tripId);

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
              trip: trip,
              onShare: () => _showShareSheet(context, trip),
              onDelete: () => _confirmDeleteTrip(context, ref, trip),
            ),
            const SizedBox(height: AppSpacing.l),
            _TripHero(trip: trip),
            const SizedBox(height: AppSpacing.l),
            _ActionGrid(trip: trip),
            const SizedBox(height: AppSpacing.l),
            _MembersSection(trip: trip),
            const SizedBox(height: AppSpacing.l),
            _OverviewSection(trip: trip),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.trip,
    required this.onShare,
    required this.onDelete,
  });

  final Trip trip;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircleButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () {
            context.go('/home');
          },
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Поездка', style: AppTextStyles.bodySmall),
              Text(
                trip.title,
                style: AppTextStyles.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        _IconCircleButton(icon: Icons.share_rounded, onPressed: onShare),
        const SizedBox(width: AppSpacing.s),
        _IconCircleButton(
          icon: Icons.delete_outline_rounded,
          onPressed: onDelete,
          iconColor: AppColors.error,
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

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
          child: Icon(icon, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _InviteStatCard extends StatelessWidget {
  const _InviteStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.l),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}

class _TripHero extends StatelessWidget {
  const _TripHero({required this.trip});

  final Trip trip;

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
          Hero(
            tag: 'trip_emoji_${trip.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                trip.coverEmoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            trip.title,
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            trip.destination,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            trip.dateRange,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.place_outlined,
                label: '${trip.votedPlacesCount} мест',
              ),
              _HeroChip(
                icon: Icons.schedule_rounded,
                label: '${trip.plannedActivitiesCount} активностей',
              ),
              _HeroChip(
                icon: Icons.groups_rounded,
                label: '${trip.members.length} участников',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Голосование за места',
        'Совместный выбор локаций',
        Icons.how_to_vote_rounded,
        () => context.push('/trip/${trip.id}/places'),
      ),
      (
        'Планировщик',
        'Таймлайн поездки по дням',
        Icons.timeline_rounded,
        () => context.push('/trip/${trip.id}/planner'),
      ),
      (
        'Бюджет',
        'Расходы и взаиморасчёты',
        Icons.account_balance_wallet_rounded,
        () => context.push('/trip/${trip.id}/budget'),
      ),
      (
        'Бронирования',
        'Билеты, жильё и заметки',
        Icons.confirmation_number_outlined,
        () => context.push('/trip/${trip.id}/bookings'),
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.l),
          onTap: item.$4,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.l),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$3, color: AppColors.primary, size: 28),
                const Spacer(),
                Text(item.$1, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(item.$2, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ).animate(delay: (120 * index).ms).fadeIn().slideY(begin: 0.06);
      },
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('Участники', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: trip.members
                .map(
                  (member) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadii.round),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member.avatar,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(member.name, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn();
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Обзор поездки', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.m),
          _OverviewRow(
            label: 'Использование бюджета',
            value:
                '₽${trip.spentBudget.toStringAsFixed(0)} / ₽${trip.totalBudget.toStringAsFixed(0)}',
          ),
          const SizedBox(height: AppSpacing.s),
          _OverviewRow(
            label: 'Добавлено мест',
            value: '${trip.votedPlacesCount}',
          ),
          const SizedBox(height: AppSpacing.s),
          _OverviewRow(
            label: 'Запланировано активностей',
            value: '${trip.plannedActivitiesCount}',
          ),
          const SizedBox(height: AppSpacing.s),
          _OverviewRow(label: 'Размер группы', value: '${trip.members.length}'),
        ],
      ),
    ).animate(delay: 350.ms).fadeIn();
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
