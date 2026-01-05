
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/providers/order_provider.dart';
import '../widgets/order/order_details_screen.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      // Use a white background to match WishlistScreen
      backgroundColor: Colors.white,
      appBar: AppBar(
        //
        // --- THIS IS THE UPDATED APPBAR ---
        //
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.titleMedium, // Matched style
        ),
        centerTitle: true, // Centered the title
        //
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.errorMessage != null
          ? Center(child: Text(orderProvider.errorMessage!))
          : orderProvider.orders.isEmpty
          ? const Center(child: Text("No orders found"))
          : RefreshIndicator(
        onRefresh: () => orderProvider.fetchOrders(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: orderProvider.orders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.orders[index];
            return OrderCard(
              order: order,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OrderDetailsScreen(order: order),
                  ),
                );
                await orderProvider.fetchOrders();
              },
            );
          },
        ),
      ),
    );
  }
}

/// Redesigned OrderCard to fit a GridView
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  // Helper to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange.shade700;
      case "processing":
        return Colors.blue.shade700;
      case "shipped":
        return Colors.blue.shade700;
      case "completed":
        return Colors.green.shade700;
      case "cancelled":
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Helper to build the status chip
  Widget _buildStatusChip(String? status) {
    status = status ?? "Unknown";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper to build the item count chip
  Widget _buildItemCountChip(int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$itemCount ${itemCount > 1 ? 'ITEMS' : 'ITEM'}",
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstImage =
    order.items?.isNotEmpty == true ? order.items!.first.image : null;
    final itemCount = order.items?.length ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image + Overlays ---
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: _OrderImage(imageUrl: firstImage),
                  ),
                  // --- Status Badge (Top-Right) ---
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildStatusChip(order.orderStatus),
                  ),
                  // --- Item Count Badge (Bottom-Left) ---
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _buildItemCountChip(itemCount),
                  ),
                ],
              ),
            ),

            // --- Text Details ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₹${order.total?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: ${order.sId ?? '-'}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Helper widget for the Order Image
class _OrderImage extends StatelessWidget {
  final String? imageUrl;
  const _OrderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.receipt_long_outlined, // More fitting for an order
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey[200]),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 40,
          ),
        ),
      ),
    );
  }
}