// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    try {
      setState(() {
        _ordersFuture = Supabase.instance.client
            .from('orders')
            .select('*')
            .eq('team_id', 'admin_team');
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _addComment(String orderId, String currentComment) async {
    try {
      final newComment = _commentController.text.isNotEmpty ? '$currentComment\n${_commentController.text}' : _commentController.text;
      await Supabase.instance.client
          .from('orders')
          .update({'comments': newComment})
          .eq('order_id', orderId)
          .eq('team_id', 'admin_team');
      _commentController.clear();
      _refreshOrders();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Error loading orders', style: TextStyle(color: Colors.red)));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Order ID: ${order['order_id']}'),
                    subtitle: Text('Total: \$${order['total']} | Comments: ${order['comments'] ?? 'None'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add Comment'),
                            content: TextField(controller: _commentController),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  _addComment(order['order_id'], order['comments'] ?? '');
                                  Navigator.pop(context);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}