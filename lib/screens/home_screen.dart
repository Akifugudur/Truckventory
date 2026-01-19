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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Truckventory',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.local_shipping, size: 90, color: Colors.amber),
            const SizedBox(height: 25),

            // 🔍 Search bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search part by name...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _searchPart(),
            ),
            const SizedBox(height: 25),

            if (_isSearching)
              const CircularProgressIndicator(color: Colors.amber)
            else if (_foundPart == null &&
                _searchController.text.trim().isNotEmpty)
              const Text(
                'No part found.',
                style: TextStyle(color: Colors.white54),
              )
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('View Part Details'),
              ),

            const SizedBox(height: 25),

            // 🔹 Main Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 3.3,
                mainAxisSpacing: 15,
                children: [
                  _buildDashboardButton(
                    context,
                    icon: Icons.add_box,
                    label: 'Add Part',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddPartScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.attach_money,
                    label: 'Sales History',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SalesHistoryScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.analytics,
                    label: 'Analysis',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnalysisScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
    );
  }
}