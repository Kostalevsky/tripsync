import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/app_scaffold.dart';
import 'package:tripsync/features/budget/domain/expense.dart';
import 'package:tripsync/features/budget/state/budget_controller.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  void _showExpenseSheet(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    Map<String, String> memberNames, {
    Expense? expense,
  }) {
    final isEditing = expense != null;

    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(0) : '',
    );
    final categoryController =
        TextEditingController(text: expense?.category ?? 'Еда');

    String selectedUserId = expense?.paidByUserId ?? memberNames.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                              borderRadius:
                                  BorderRadius.circular(AppRadii.round),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Text(
                          isEditing ? 'Редактировать расход' : 'Добавить расход',
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Название расхода',
                            hintText: 'Например: Ужин, Такси, Билеты',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                          labelText: 'Сумма (₽)',
                          hintText: 'Например: 12000',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Категория',
                            hintText: 'Еда / Жильё / Транспорт / Активности',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'Оплатил',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        DropdownButtonFormField<String>(
                          value: selectedUserId,
                          items: memberNames.entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() {
                              selectedUserId = value;
                            });
                          },
                          decoration: const InputDecoration(),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              final title = titleController.text.trim();
                              final category = categoryController.text.trim();
                              final amount =
                                  double.tryParse(amountController.text.trim());

                              if (title.isEmpty ||
                                  category.isEmpty ||
                                  amount == null ||
                                  amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Заполните корректно все поля',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final nextExpense = Expense(
                                id: expense?.id ??
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                title: title,
                                paidByUserId: selectedUserId,
                                amount: amount,
                                category: category,
                              );

                              if (isEditing) {
                                ref
                                    .read(budgetControllerProvider.notifier)
                                    .updateExpense(
                                      tripId: tripId,
                                      updatedExpense: nextExpense,
                                    );
                              } else {
                                ref
                                    .read(budgetControllerProvider.notifier)
                                    .addExpense(
                                      tripId: tripId,
                                      expense: nextExpense,
                                    );
                              }

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Расход обновлён'
                                        : 'Расход добавлен',
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
      },
    );
  }

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    Expense expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить расход?'),
              content: Text(
                'Статья "${expense.title}" будет удалена из бюджета.',
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

    ref.read(budgetControllerProvider.notifier).deleteExpense(
          tripId: tripId,
          expenseId: expense.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Расход удалён'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.read(tripsControllerProvider.notifier).getById(tripId);
    final expensesState = ref.watch(budgetControllerProvider);
    final expenses = expensesState[tripId] ?? const <Expense>[];
    final settlements =
        ref.read(budgetControllerProvider.notifier).calculateSettlements(tripId);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

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
              onAdd: () => _showExpenseSheet(
                context,
                ref,
                tripId,
                memberNames,
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
                    '₽${total.toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Добавляйте, редактируйте и удаляйте статьи расходов. Перерасчёт выполняется автоматически.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Container(
              height: 240,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: categoryTotals.isEmpty
                  ? Center(
                      child: Text(
                        'Добавьте первый расход,\nчтобы увидеть структуру бюджета',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        sections: categoryTotals.entries.map((entry) {
                          final value = entry.value;
                          return PieChartSectionData(
                            value: value,
                            title: '${entry.key}\n₽${value.toStringAsFixed(0)}',
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
                  Row(
                    children: [
                      Expanded(
                        child: Text('Расходы', style: AppTextStyles.titleLarge),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showExpenseSheet(
                          context,
                          ref,
                          tripId,
                          memberNames,
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Добавить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (expenses.isEmpty)
                    Text(
                      'Пока нет расходов. Добавьте первую статью бюджета.',
                      style: AppTextStyles.bodyMedium,
                    )
                  else
                    ...expenses.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: InkWell(
                          onTap: () => _showExpenseSheet(
                            context,
                            ref,
                            tripId,
                            memberNames,
                            expense: expense,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.l),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadii.l),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.title,
                                        style: AppTextStyles.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${expense.category} • оплатил ${memberNames[expense.paidByUserId] ?? 'участник'}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₽${expense.amount.toStringAsFixed(0)}',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.s),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _showExpenseSheet(
                                            context,
                                            ref,
                                            tripId,
                                            memberNames,
                                            expense: expense,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.round,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
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
                                              Icons.edit_outlined,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.s),
                                        InkWell(
                                          onTap: () => _confirmDeleteExpense(
                                            context,
                                            ref,
                                            tripId,
                                            expense,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.round,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
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
                          ),
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
                            '₽${settlement.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                      ),
                    ),
                ],
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
        Expanded(child: Text(title, style: AppTextStyles.headlineLarge)),
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