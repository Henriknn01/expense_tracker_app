import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState(){
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(title: 'Flutter Course', amount: 19.99, date: DateTime.now(), category: Category.work),
    Expense(title: 'Burger', amount: 29.99, date: DateTime.now(), category: Category.food),
    Expense(title: 'Plane ticket', amount: 119.99, date: DateTime.now(), category: Category.travel),
  ];

  CategoryFilter _selectedFilter = CategoryFilter.all;

  List<Expense> _filteredExpenses = [];

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense));
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense deleted'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, expense);
              });
            },
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(child: Text('No expenses found.'));

    if (_selectedFilter != CategoryFilter.all) {
      _filteredExpenses = _registeredExpenses.where((expense) => expense.category.name == _selectedFilter.name).toList();
    }
    else {
      _filteredExpenses = _registeredExpenses;
    }

    if (_filteredExpenses.isNotEmpty) {
      mainContent = ExpensesList(expenses: _filteredExpenses, onRemoveExpense: _removeExpense,);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter expense tracker'),
        actions: [
          IconButton(onPressed: _openAddExpenseOverlay, icon: Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16,),
          Text("Expense summary", style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900)),
          Chart(expenses: _registeredExpenses),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            width: double.infinity,
            child: Row(
            children: [
              Expanded(child: Text("Recent expenses", style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900))),
              Row(
                children: [
                  Text("Filter", textAlign: TextAlign.left,),
                  SizedBox(width: 16),
                  DropdownButton(
                      value: _selectedFilter,
                      items: CategoryFilter.values.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name.toUpperCase()),
                      ),
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        };
                        setState(() {
                         _selectedFilter = value;
                        }
                      );
                    }
                  ),
                ],
              )
            ],
          )
          ),
          Expanded(child: mainContent)
        ],
      ),
    );
  }
}
