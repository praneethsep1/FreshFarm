import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this for charts
import '../authentication.dart';
import '../models.dart';

class FarmerSalesAnalytics extends StatelessWidget {
  const FarmerSalesAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final farmerId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTotalRevenueCard(farmerId),
            const SizedBox(height: 16),
            _buildTopProductsCard(farmerId),
            const SizedBox(height: 16),
            _buildOrderTrendsChart(farmerId),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(String farmerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        double totalRevenue = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final orderData = doc.data() as Map<String, dynamic>;
            final items = (orderData['items'] as List)
                .map((item) => CartItem.fromMap(item))
                .where((item) => item.farmerId == farmerId)
                .toList();
            totalRevenue += items.fold(
                0, (sum, item) => sum + (item.price * item.quantity));
          }
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProductsCard(String farmerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        Map<String, Map<String, dynamic>> productSales = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final orderData = doc.data() as Map<String, dynamic>;
            final items = (orderData['items'] as List)
                .map((item) => CartItem.fromMap(item))
                .where((item) => item.farmerId == farmerId)
                .toList();
            for (var item in items) {
              productSales[item.productId] ??= {
                'name': item.productName,
                'quantity': 0,
                'revenue': 0.0,
              };
              productSales[item.productId]!['quantity'] += item.quantity;
              productSales[item.productId]!['revenue'] +=
                  item.price * item.quantity;
            }
          }
        }

        final topProducts = productSales.entries.toList()
          ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));
        final topFive = topProducts.take(5).toList();

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Selling Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...topFive.map((entry) => ListTile(
                      title: Text(entry.value['name']),
                      subtitle: Text(
                          'Sold: ${entry.value['quantity']} | ₹${entry.value['revenue'].toStringAsFixed(2)}'),
                    )),
                if (topFive.isEmpty)
                  const Text('No sales data available',
                      style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTrendsChart(String farmerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: 30))))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        Map<String, double> dailyRevenue = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final orderData = doc.data() as Map<String, dynamic>;
            final createdAt = (orderData['createdAt'] as Timestamp).toDate();
            final dateKey =
                '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
            final items = (orderData['items'] as List)
                .map((item) => CartItem.fromMap(item))
                .where((item) => item.farmerId == farmerId)
                .toList();
            final revenue = items.fold(
                0, (sum, item) => sum + (item.price * item.quantity).toInt());
            dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + revenue;
          }
        }

        final spots = dailyRevenue.entries.map((entry) {
          final date = DateTime.parse(entry.key);
          final dayOffset = DateTime.now().difference(date).inDays;
          return FlSpot(30 - dayOffset.toDouble(), entry.value);
        }).toList()
          ..sort((a, b) => a.x.compareTo(b.x));

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Trends (Last 30 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) =>
                                Text('₹${value.toInt()}'),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                Text('${30 - value.toInt()}d'),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: 30,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.green,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
