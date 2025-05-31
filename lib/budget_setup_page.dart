import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetSetupPage extends StatefulWidget {
  const BudgetSetupPage({Key? key}) : super(key: key);

  @override
  State<BudgetSetupPage> createState() => _BudgetSetupPageState();
}

class _BudgetSetupPageState extends State<BudgetSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetController = TextEditingController();
  String? _editingDocId;

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      final double budget = double.parse(_budgetController.text);

      try {
        if (_editingDocId == null) {
          await FirebaseFirestore.instance.collection('budgets').add({
            'budget': budget,
            'created_at': Timestamp.now(),
          });
        } else {
          await FirebaseFirestore.instance
              .collection('budgets')
              .doc(_editingDocId)
              .update({'budget': budget, 'updated_at': Timestamp.now()});
          _editingDocId = null;
        }

        _budgetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteBudget(String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Budget'),
            content: const Text('Are you sure you want to delete this budget?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm) {
      await FirebaseFirestore.instance
          .collection('budgets')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget deleted')));
    }
  }

  void _editBudget(DocumentSnapshot doc) {
    setState(() {
      _editingDocId = doc.id;
      _budgetController.text = doc['budget'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Your Total Budget:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a budget';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveBudget,
                    child: Text(
                      _editingDocId == null ? 'Save Budget' : 'Update Budget',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Saved Budgets:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('budgets')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error loading budgets');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text('No budget entries yet.');
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final budget = doc['budget'];
                      final createdAt =
                          (doc['created_at'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('RM ${budget.toStringAsFixed(2)}'),
                          subtitle: Text('Created: ${createdAt.toLocal()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editBudget(doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteBudget(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
