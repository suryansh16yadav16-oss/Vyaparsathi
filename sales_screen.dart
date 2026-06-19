import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/bill_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, dynamic> _salesData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final provider = Provider.of<BillProvider>(context, listen: false);
    final data = await provider.getTodaySales();
    setState(() {
      _salesData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Sales")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 30),
                  _buildStatCard(
                    context,
                    'Revenue',
                    '₹${_salesData['revenue']?.toStringAsFixed(2) ?? '0.00'}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    context,
                    'Number of Bills',
                    '${_salesData['billCount'] ?? 0}',
                    Icons.receipt,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    context,
                    'Products Sold',
                    '${_salesData['productsSold'] ?? 0}',
                    Icons.shopping_bag,
                    Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
