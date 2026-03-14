import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/budget/domain/expense.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, Map<String, List<Expense>>>(
      (ref) => BudgetController(ref),
    );

class BudgetController extends StateNotifier<Map<String, List<Expense>>> {
  BudgetController(this._ref) : super(_demoExpenses);

  final Ref _ref;

  List<Expense> getExpensesForTrip(String tripId) {
    return state[tripId] ?? const <Expense>[];
  }

  double getTotalForTrip(String tripId) {
    return getExpensesForTrip(tripId).fold(0, (sum, e) => sum + e.amount);
  }

  void addExpense({required String tripId, required Expense expense}) {
    final current = [...(state[tripId] ?? const <Expense>[])];
    current.insert(0, expense);

    state = {...state, tripId: current};
  }

  void updateExpense({
    required String tripId,
    required Expense updatedExpense,
  }) {
    final current = [...(state[tripId] ?? const <Expense>[])];
    final index = current.indexWhere(
      (expense) => expense.id == updatedExpense.id,
    );

    if (index == -1) return;

    current[index] = updatedExpense;

    state = {...state, tripId: current};
  }

  void deleteExpense({required String tripId, required String expenseId}) {
    final current = [...(state[tripId] ?? const <Expense>[])];
    current.removeWhere((expense) => expense.id == expenseId);

    state = {...state, tripId: current};
  }

  List<Settlement> calculateSettlements(String tripId) {
    final trip = _ref.read(tripsControllerProvider.notifier).getById(tripId);
    final expenses = getExpensesForTrip(tripId);

    if (trip == null || trip.members.isEmpty || expenses.isEmpty) {
      return const <Settlement>[];
    }

    final memberIds = trip.members.map((m) => m.id).toList();
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final share = total / memberIds.length;

    final paid = <String, double>{for (final id in memberIds) id: 0};

    for (final expense in expenses) {
      paid[expense.paidByUserId] =
          (paid[expense.paidByUserId] ?? 0) + expense.amount;
    }

    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    for (final id in memberIds) {
      final balance = (paid[id] ?? 0) - share;
      if (balance < 0) {
        debtors.add(MapEntry(id, -balance));
      } else if (balance > 0) {
        creditors.add(MapEntry(id, balance));
      }
    }

    final results = <Settlement>[];
    int i = 0;
    int j = 0;

    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final amount = debtor.value < creditor.value
          ? debtor.value
          : creditor.value;

      results.add(
        Settlement(
          fromUserId: debtor.key,
          toUserId: creditor.key,
          amount: double.parse(amount.toStringAsFixed(2)),
        ),
      );

      debtors[i] = MapEntry(debtor.key, debtor.value - amount);
      creditors[j] = MapEntry(creditor.key, creditor.value - amount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return results;
  }

  static final Map<String, List<Expense>> _demoExpenses = {
    'trip_amsterdam': const [
      Expense(
        id: 'e1',
        title: 'Апартаменты',
        paidByUserId: '1',
        amount: 640,
        category: 'Жильё',
      ),
      Expense(
        id: 'e2',
        title: 'Музейные билеты',
        paidByUserId: '2',
        amount: 180,
        category: 'Активности',
      ),
      Expense(
        id: 'e3',
        title: 'Круиз по каналам',
        paidByUserId: '3',
        amount: 120,
        category: 'Активности',
      ),
      Expense(
        id: 'e4',
        title: 'Групповой ужин',
        paidByUserId: '4',
        amount: 220,
        category: 'Еда',
      ),
      Expense(
        id: 'e5',
        title: 'Такси и транспорт',
        paidByUserId: '1',
        amount: 90,
        category: 'Транспорт',
      ),
    ],
    'trip_barcelona': const [
      Expense(
        id: 'b1',
        title: 'Отель',
        paidByUserId: '1',
        amount: 400,
        category: 'Жильё',
      ),
      Expense(
        id: 'b2',
        title: 'Ужин tapas',
        paidByUserId: '6',
        amount: 120,
        category: 'Еда',
      ),
      Expense(
        id: 'b3',
        title: 'Трансфер',
        paidByUserId: '5',
        amount: 100,
        category: 'Транспорт',
      ),
    ],
    'trip_tokyo': const [
      Expense(
        id: 't1',
        title: 'Отель',
        paidByUserId: '1',
        amount: 700,
        category: 'Жильё',
      ),
      Expense(
        id: 't2',
        title: 'Shibuya Sky',
        paidByUserId: '8',
        amount: 140,
        category: 'Активности',
      ),
      Expense(
        id: 't3',
        title: 'Ужин',
        paidByUserId: '7',
        amount: 110,
        category: 'Еда',
      ),
    ],
  };
}
