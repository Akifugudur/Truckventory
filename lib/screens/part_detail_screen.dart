import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // 1️⃣ Yeni satış kaydını ekle
      await _firestore.collection('sales').add({
        'partId': widget.docId,
        'partName': widget.part['name'],
        'quantity': quantity,
        'price': widget.part['price'],
        'totalPrice': widget.part['price'] * quantity,
        'date': DateTime.now(),
      });

      // 2️⃣ Stok güncelle
      if (widget.docId != null) {
        final newStock = (widget.part['stock'] ?? 0) - quantity;
        await _firestore.collection('parts').doc(widget.docId).update({
          'stock': newStock < 0 ? 0 : newStock,
        });
        setState(() => widget.part['stock'] = newStock < 0 ? 0 : newStock);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sale recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _quantityController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Error while selling: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          part['name'],
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.build_circle,
                    size: 110, color: Colors.amber.shade700),
              ),
              const SizedBox(height: 25),
              _buildInfoRow("🧾 Name", part['name']),
              _buildInfoRow("💰 Price", "₺${part['price']}"),
              _buildInfoRow("📦 Stock", part['stock'].toString()),
              _buildInfoRow("📍 Location", part['location']),
              const Divider(height: 40, color: Colors.white30),
              const Text(
                "💸 Sell this Part",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quantity to sell',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isSelling
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.sell, color: Colors.black),
                      label: const Text(
                        'Confirm Sale',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _sellPart,
                    ),
              const SizedBox(height: 30),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                  label: const Text(
                    "Back to Home",
                    style: TextStyle(color: Colors.amber, fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}