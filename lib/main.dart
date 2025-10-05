import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HomePage(),
    );
  }
}

// Data Models
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });
}

class BudgetPlan {
  final String category;
  final double budgetAmount;
  final double spentAmount;

  BudgetPlan({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
  });

  double get remainingAmount => budgetAmount - spentAmount;
  double get percentageUsed => (spentAmount / budgetAmount * 100).clamp(0, 100);
}

// Home Page with Dashboard
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaction> transactions = [
    Transaction(
      id: '1',
      title: 'Salary',
      amount: 5000.00,
      category: 'Income',
      date: DateTime.now().subtract(Duration(days: 1)),
      isIncome: true,
    ),
    Transaction(
      id: '2',
      title: 'Groceries',
      amount: 150.00,
      category: 'Food',
      date: DateTime.now().subtract(Duration(days: 2)),
      isIncome: false,
    ),
    Transaction(
      id: '3',
      title: 'Gas',
      amount: 60.00,
      category: 'Transportation',
      date: DateTime.now().subtract(Duration(days: 3)),
      isIncome: false,
    ),
  ];

  List<BudgetPlan> budgetPlans = [
    BudgetPlan(category: 'Food', budgetAmount: 500, spentAmount: 150),
    BudgetPlan(category: 'Transportation', budgetAmount: 200, spentAmount: 60),
    BudgetPlan(category: 'Entertainment', budgetAmount: 300, spentAmount: 80),
    BudgetPlan(category: 'Shopping', budgetAmount: 400, spentAmount: 220),
  ];

  double get totalIncome {
    return transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get availableBalance => totalIncome - totalExpenses;

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      // Update budget if it's an expense
      if (!transaction.isIncome) {
        for (int i = 0; i < budgetPlans.length; i++) {
          if (budgetPlans[i].category == transaction.category) {
            budgetPlans[i] = BudgetPlan(
              category: budgetPlans[i].category,
              budgetAmount: budgetPlans[i].budgetAmount,
              spentAmount: budgetPlans[i].spentAmount + transaction.amount,
            );
            break;
          }
        }
      }
    });
  }

  void _updateBudgetPlan(String category, double newBudget) {
    setState(() {
      for (int i = 0; i < budgetPlans.length; i++) {
        if (budgetPlans[i].category == category) {
          budgetPlans[i] = BudgetPlan(
            category: budgetPlans[i].category,
            budgetAmount: newBudget,
            spentAmount: budgetPlans[i].spentAmount,
          );
          break;
        }
      }
    });
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Cards
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  'Available Balance',
                  availableBalance,
                  Colors.green,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  'Income',
                  totalIncome,
                  Colors.blue,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBalanceCard(
                  'Expenses',
                  totalExpenses,
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Recent Transactions
          Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = transactions[transactions.length - 1 - index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
                    child: Icon(
                      transaction.isIncome ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(transaction.category),
                  trailing: Text(
                    '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          ExpensePage(onAddTransaction: _addTransaction),
          BudgetPage(
            budgetPlans: budgetPlans,
            onUpdateBudget: _updateBudgetPlan,
          ),
          TransactionsPage(transactions: transactions),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}

// Add Expense Page
class ExpensePage extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  ExpensePage({required this.onAddTransaction});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _isIncome = false;

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Education',
    'Income',
    'Other',
  ];

  void _addTransaction() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: DateTime.now(),
      isIncome: _isIncome,
    );

    widget.onAddTransaction(transaction);

    _titleController.clear();
    _amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Transaction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Income/Expense Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIncome = false),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !_isIncome ? Colors.red : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: !_isIncome ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIncome = true),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isIncome ? Colors.green : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: _isIncome ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Transaction Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            SizedBox(height: 32),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Budget Planning Page
class BudgetPage extends StatefulWidget {
  final List<BudgetPlan> budgetPlans;
  final Function(String, double) onUpdateBudget;

  BudgetPage({required this.budgetPlans, required this.onUpdateBudget});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  void _editBudget(BudgetPlan plan) {
    final controller = TextEditingController(
      text: plan.budgetAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${plan.category} Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text);
              if (newBudget != null && newBudget > 0) {
                widget.onUpdateBudget(plan.category, newBudget);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tap on any budget item to edit',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: widget.budgetPlans.length,
                itemBuilder: (context, index) {
                  final plan = widget.budgetPlans[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => _editBudget(plan),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.category,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.edit, color: Colors.grey[600]),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Spent: \$${plan.spentAmount.toStringAsFixed(2)}'),
                                Text('Budget: \$${plan.budgetAmount.toStringAsFixed(2)}'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Remaining: \$${plan.remainingAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: plan.remainingAmount >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: plan.percentageUsed / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation(
                                plan.percentageUsed > 100 ? Colors.red :
                                plan.percentageUsed > 80 ? Colors.orange : Colors.green,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${plan.percentageUsed.toStringAsFixed(1)}% used',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Transactions History Page
class TransactionsPage extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionsPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = List<Transaction>.from(transactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Transactions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: sortedTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = sortedTransactions[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
                        child: Icon(
                          transaction.isIncome ? Icons.add : Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(transaction.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction.category),
                          Text(
                            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction.isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}