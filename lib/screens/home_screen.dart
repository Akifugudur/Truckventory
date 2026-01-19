import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truckventory/screens/sales_history.dart';
import 'part_detail_screen.dart';
import 'add_part_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSearching = false;
  Map<String, dynamic>? _foundPart;

  Future<void> _searchPart() async {
    setState(() {
      _isSearching = true;
      _foundPart = null;
    });

    final querySnapshot = await _firestore
        .collection('parts')
        .where('name', isEqualTo: _searchController.text.trim())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _foundPart = querySnapshot.docs.first.data();
      });
    } else {
      setState(() {
        _foundPart = null;
      });
    }

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truckventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.local_shipping, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Part by Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPart,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (_isSearching)
              const CircularProgressIndicator()
            else if (_foundPart == null && _searchController.text.isNotEmpty)
              const Text('No part found.')
            else if (_foundPart != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartDetailScreen(part: _foundPart!),
                    ),
                  );
                },
                child: const Text('View Part Details'),
              ),

            const SizedBox(height: 40),

            // 🔹 Main Buttons Section 🔹
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_box),
                    label: const Text('Add Part'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPartScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Sales'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analysis'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalysisScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}