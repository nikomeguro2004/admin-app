// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_editor.dart';
import 'orders.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _ordersFuture = Supabase.instance.client
            .from('orders')
            .select('total, order_id')
            .eq('team_id', 'admin_team');
      });
      final test = await Supabase.instance.client.from('orders').select('order_id').limit(1);
      print('Debug query result: $test');
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: NavigationBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              selectedIndex: 0,
              onDestinationSelected: (index) {
                if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuEditorScreen()));
                if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
                NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text('Error: ${snapshot.error ?? 'No data'}', style: const TextStyle(color: Colors.red)));
            }
            final orders = snapshot.data!;
            final ordersCount = orders.length;
            final revenue = orders.isEmpty ? 0.0 : orders.fold(0.0, (sum, order) => sum + (order['total'] as num).toDouble());
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard('Revenue', '\$${revenue.toStringAsFixed(2)}', Colors.green),
                  _buildMetricCard('Orders', '$ordersCount', Colors.blue),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withAlpha(25),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}