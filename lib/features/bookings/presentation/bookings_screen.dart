import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/bookings/domain/booking_item.dart';
import 'package:tripsync/features/bookings/state/bookings_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  void _showBookingSheet(
    BuildContext context,
    WidgetRef ref,
    String tripId, {
    BookingItem? booking,
  }) {
    final isEditing = booking != null;

    final titleController = TextEditingController(text: booking?.title ?? '');
    final detailsController =
        TextEditingController(text: booking?.details ?? '');
    final dateController =
        TextEditingController(text: booking?.dateLabel ?? '');
    final typeController = TextEditingController(text: booking?.type ?? 'Жильё');
    final statusController =
        TextEditingController(text: booking?.status ?? 'Черновик');
    final emojiController = TextEditingController(text: booking?.emoji ?? '🏠');

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
                          ? 'Редактировать бронирование'
                          : 'Добавить бронирование',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Например: Отель, Билеты, Трансфер',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Тип',
                        hintText: 'Авиабилеты / Жильё / Трансфер',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Детали',
                        hintText: 'Короткая информация о бронировании',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Дата',
                        hintText: 'Например: 12 апр 2026',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(
                        labelText: 'Статус',
                        hintText: 'Забронировано / Ожидает / Черновик',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextField(
                      controller: emojiController,
                      decoration: const InputDecoration(
                        labelText: 'Эмодзи',
                        hintText: 'Например: ✈️',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final type = typeController.text.trim();
                          final details = detailsController.text.trim();
                          final dateLabel = dateController.text.trim();
                          final status = statusController.text.trim();
                          final emoji = emojiController.text.trim();

                          if (title.isEmpty ||
                              type.isEmpty ||
                              details.isEmpty ||
                              dateLabel.isEmpty ||
                              status.isEmpty ||
                              emoji.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Заполните все поля'),
                              ),
                            );
                            return;
                          }

                          final next = BookingItem(
                            id: booking?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            title: title,
                            type: type,
                            details: details,
                            status: status,
                            dateLabel: dateLabel,
                            emoji: emoji,
                          );

                          if (isEditing) {
                            ref
                                .read(bookingsControllerProvider.notifier)
                                .updateBooking(
                                  tripId: tripId,
                                  updatedBooking: next,
                                );
                          } else {
                            ref
                                .read(bookingsControllerProvider.notifier)
                                .addBooking(
                                  tripId: tripId,
                                  booking: next,
                                );
                          }

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Бронирование обновлено'
                                    : 'Бронирование добавлено',
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

  Future<void> _confirmDeleteBooking(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    BookingItem booking,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить бронирование?'),
              content: Text(
                'Бронирование "${booking.title}" будет удалено.',
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

    ref.read(bookingsControllerProvider.notifier).deleteBooking(
          tripId: tripId,
          bookingId: booking.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Бронирование удалено'),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'забронировано':
        return Colors.green;
      case 'ожидает':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final bookings = ref.watch(bookingsControllerProvider)[tripId] ??
        const <BookingItem>[];

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
              title: 'Бронирования',
              onBack: () => context.pop(),
              onAdd: () => _showBookingSheet(context, ref, tripId),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Храните ключевые бронирования поездки: жильё, транспорт и билеты.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            if (bookings.isEmpty)
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
                    const Text('🧾', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Пока нет бронирований',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Добавьте первое бронирование для поездки.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    FilledButton.icon(
                      onPressed: () => _showBookingSheet(context, ref, tripId),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Добавить бронирование'),
                    ),
                  ],
                ),
              )
            else
              ...bookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: InkWell(
                    onTap: () => _showBookingSheet(
                      context,
                      ref,
                      tripId,
                      booking: booking,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.l),
                            ),
                            child: Text(
                              booking.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.title,
                                  style: AppTextStyles.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${booking.type} • ${booking.dateLabel}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Text(
                                  booking.details,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.m,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(booking.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.round),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style:
                                        AppTextStyles.bodySmall.copyWith(
                                      color: _statusColor(booking.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Column(
                            children: [
                              _SmallActionButton(
                                icon: Icons.edit_outlined,
                                iconColor: AppColors.primary,
                                onPressed: () => _showBookingSheet(
                                  context,
                                  ref,
                                  tripId,
                                  booking: booking,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              _SmallActionButton(
                                icon: Icons.delete_outline_rounded,
                                iconColor: AppColors.error,
                                onPressed: () => _confirmDeleteBooking(
                                  context,
                                  ref,
                                  tripId,
                                  booking,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.round),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.textPrimary,
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
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}