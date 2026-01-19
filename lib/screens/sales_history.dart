import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for date formatting

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('sales')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No sales yet."));
          }

          final sales = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              final date = (sale['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy – HH:mm').format(date);
              final partId = sale['partId'];
              final qty = sale['quantity'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: Text("Part ID: $partId"),
                  subtitle: Text("Quantity: $qty\nDate: $formattedDate"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}