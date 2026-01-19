import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedPartId;
  int _quantity = 1;
  bool _isSaving = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Part:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('parts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final parts = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: _selectedPartId,
                  hint: const Text("Choose a part"),
                  items: parts.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPartId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity Sold",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                _quantity = int.tryParse(val) ?? 1;
              },
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Transaction"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
            const SizedBox(height: 20),
            if (_message != null)
              Center(
                child: Text(
                  _message!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedPartId == null) {
      setState(() => _message = "Please select a part.");
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    final partRef = _firestore.collection('parts').doc(_selectedPartId);
    final partSnap = await partRef.get();

    if (!partSnap.exists) {
      setState(() {
        _isSaving = false;
        _message = "Part not found.";
      });
      return;
    }

    final currentStock = partSnap['stock'];
    final newStock = currentStock - _quantity;

    if (newStock < 0) {
      setState(() {
        _isSaving = false;
        _message = "Not enough stock.";
      });
      return;
    }

    await _firestore.collection('sales').add({
      'partId': _selectedPartId,
      'quantity': _quantity,
      'date': Timestamp.now(),
    });

    await partRef.update({'stock': newStock});

    setState(() {
      _isSaving = false;
      _message = "Transaction saved successfully.";
      _selectedPartId = null;
      _quantity = 1;
    });
  }
}