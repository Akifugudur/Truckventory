import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartDetailScreen extends StatefulWidget {
  final Map<String, dynamic> part;
  final String? docId;

  const PartDetailScreen({Key? key, required this.part, this.docId})
      : super(key: key);

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _quantityController = TextEditingController();

  bool _isSelling = false;

  Future<void> _sellPart() async {
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;

    setState(() => _isSelling = true);

    try {
      // 🔹 1. Yeni satış kaydını ekle
      await _firestore.collection('sales').add({
        'partName': widget.part['name'],
        'quantity': quantity,
        'price': widget.part['price'],
        'totalPrice': widget.part['price'] * quantity,
        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      });

      // 🔹 2. Stok güncelle (part’ın document id’si varsa)
      if (widget.docId != null) {
        final newStock = (widget.part['stock'] ?? 0) - quantity;
        await _firestore.collection('parts').doc(widget.docId).update({
          'stock': newStock < 0 ? 0 : newStock,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale recorded successfully ✅')),
      );

      setState(() {
        _isSelling = false;
        widget.part['stock'] =
            (widget.part['stock'] ?? 0) - quantity; // ekranda da azalsın
      });
      _quantityController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isSelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;

    return Scaffold(
      appBar: AppBar(
        title: Text(part['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.build, size: 100, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              Text('🧾 Name: ${part['name']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('💰 Price: ₺${part['price']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('📦 Stock: ${part['stock']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('📍 Location: ${part['location']}', style: const TextStyle(fontSize: 18)),

              const Divider(height: 40),

              Text('💸 Sell this Part', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to sell',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              _isSelling
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.sell),
                      label: const Text('Confirm Sale'),
                      onPressed: _sellPart,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}