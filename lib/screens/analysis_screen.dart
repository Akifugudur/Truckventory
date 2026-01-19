import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double totalRevenue = 0;
  int totalSales = 0;
  Map<String, int> productSales = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalysisData();
  }

  Future<void> _fetchAnalysisData() async {
    final snapshot = await _firestore.collection('sales').get();

    double revenue = 0;
    int salesCount = 0;
    Map<String, int> productMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final partId = data['partId'] ?? 'Unknown';
      final quantity = (data['quantity'] ?? 0) as int;
      final price = (data['price'] ?? 0).toDouble();

      revenue += quantity * price;
      salesCount += quantity;
      productMap[partId] = (productMap[partId] ?? 0) + quantity;
    }

    setState(() {
      totalRevenue = revenue;
      totalSales = salesCount;
      productSales = productMap;
    });
  }

  List<BarChartGroupData> _generateChartData() {
    int i = 0;
    return productSales.entries.map((entry) {
      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blueGrey,
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Analysis"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📊 Overall Statistics",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                child: ListTile(
                  title: const Text("Total Sales"),
                  trailing: Text("$totalSales items"),
                ),
              ),
              Card(
                elevation: 3,
                child: ListTile(
                  title: const Text("Total Revenue"),
                  trailing: Text("\$${totalRevenue.toStringAsFixed(2)}"),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "🏆 Top Selling Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (productSales.isEmpty)
                const Center(child: Text("No sales data yet."))
              else
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final keys = productSales.keys.toList();
                              if (value.toInt() < keys.length) {
                                return Transform.rotate(
                                  angle: -0.5,
                                  child: Text(keys[value.toInt()],
                                      style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      barGroups: _generateChartData(),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}