import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/budget/state/budget_controller.dart';
import 'package:tripsync/features/budget/domain/expense.dart';

void main() {
  test('addExpense adds expense to trip', () {
    final container = ProviderContainer();
    final controller = container.read(budgetControllerProvider.notifier);

    final expense = Expense(
      id: 'exp1',
      title: 'Dinner',
      paidByUserId: '1',
      amount: 50,
      category: 'Food',
    );

    controller.addExpense(tripId: 'trip_test', expense: expense);

    final expenses = controller.getExpensesForTrip('trip_test');

    expect(expenses.length, 1);
    expect(expenses.first.title, 'Dinner');
  });

  test('getTotalForTrip calculates total correctly', () {
    final container = ProviderContainer();
    final controller = container.read(budgetControllerProvider.notifier);

    controller.addExpense(
      tripId: 'trip_test',
      expense: Expense(
        id: '1',
        title: 'Hotel',
        paidByUserId: '1',
        amount: 100,
        category: 'Stay',
      ),
    );

    controller.addExpense(
      tripId: 'trip_test',
      expense: Expense(
        id: '2',
        title: 'Food',
        paidByUserId: '2',
        amount: 50,
        category: 'Food',
      ),
    );

    final total = controller.getTotalForTrip('trip_test');

    expect(total, 150);
  });

  test('updateExpense updates existing expense', () {
    final container = ProviderContainer();
    final controller = container.read(budgetControllerProvider.notifier);

    controller.addExpense(
      tripId: 'trip_test',
      expense: Expense(
        id: 'exp1',
        title: 'Lunch',
        paidByUserId: '1',
        amount: 20,
        category: 'Food',
      ),
    );

    controller.updateExpense(
      tripId: 'trip_test',
      updatedExpense: Expense(
        id: 'exp1',
        title: 'Lunch Updated',
        paidByUserId: '1',
        amount: 30,
        category: 'Food',
      ),
    );

    final expenses = controller.getExpensesForTrip('trip_test');

    expect(expenses.first.amount, 30);
  });

  test('deleteExpense removes expense', () {
    final container = ProviderContainer();
    final controller = container.read(budgetControllerProvider.notifier);

    controller.addExpense(
      tripId: 'trip_test',
      expense: Expense(
        id: 'exp_delete',
        title: 'Taxi',
        paidByUserId: '1',
        amount: 15,
        category: 'Transport',
      ),
    );

    controller.deleteExpense(tripId: 'trip_test', expenseId: 'exp_delete');

    final expenses = controller.getExpensesForTrip('trip_test');

    expect(expenses, isEmpty);
  });
}
