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
      final partName = data['partName'] ?? 'Unknown Part';
      final quantity = (data['quantity'] ?? 0) as int;
      final price = (data['price'] ?? 0).toDouble();

      revenue += quantity * price;
      salesCount += quantity;
      productMap[partName] = (productMap[partName] ?? 0) + quantity;
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
            color: Colors.amber,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Sales Analysis",
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📊 Overall Statistics",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Total Sales & Revenue Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: const Text(
                          "Total Sales",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          "$totalSales pcs",
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: const Text(
                          "Total Revenue",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          "₺${totalRevenue.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              const Text(
                "🏆 Top Selling Products",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              if (productSales.isEmpty)
                const Center(
                  child: Text(
                    "No sales data yet.",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              else
                Container(
                  height: 350,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) {
                              final keys = productSales.keys.toList();
                              if (value.toInt() < keys.length) {
                                return Transform.rotate(
                                  angle: -0.6,
                                  child: Text(
                                    keys[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      barGroups: _generateChartData(),
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