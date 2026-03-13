import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/budget/state/budget_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final expenses = ref.watch(budgetControllerProvider.notifier).getExpensesForTrip(tripId);
    final settlements =
        ref.watch(budgetControllerProvider.notifier).calculateSettlements(tripId);
    final total = ref.watch(budgetControllerProvider.notifier).getTotalForTrip(tripId);

    if (trip == null) {
      return const Scaffold(
        body: Center(child: Text('Поездка не найдена')),
      );
    }

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final memberNames = {
      for (final member in trip.members) member.id: member.name,
    };

    return AppScaffold(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              title: 'Бюджет',
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
                  Text('Общие расходы', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    '€${total.toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Ниже показана структура расходов и автоматический расчёт “кто кому должен”.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: AppSpacing.l),
            Container(
              height: 240,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: categoryTotals.entries.map((entry) {
                    final value = entry.value;
                    return PieChartSectionData(
                      value: value,
                      title: '${entry.key}\n€${value.toStringAsFixed(0)}',
                      radius: 64,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Container(
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
                  Text('Расходы', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.m),
                  ...expenses.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expense.title, style: AppTextStyles.titleMedium),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${expense.category} • оплатил ${memberNames[expense.paidByUserId] ?? 'участник'}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '€${expense.amount.toStringAsFixed(0)}',
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Кто кому должен', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.m),
                  if (settlements.isEmpty)
                    Text(
                      'Все расчёты уже сбалансированы.',
                      style: AppTextStyles.bodyMedium,
                    )
                  else
                    ...settlements.map(
                      (settlement) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadii.l),
                          ),
                          child: Text(
                            '${memberNames[settlement.fromUserId] ?? settlement.fromUserId} → '
                            '${memberNames[settlement.toUserId] ?? settlement.toUserId} '
                            '€${settlement.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ).animate(delay: 150.ms).fadeIn(),
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
        Expanded(child: Text(title, style: AppTextStyles.headlineLarge)),
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