
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../snackbar_fxn.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isPaying = false;
  bool isUpdating = false;

  Future<void> payOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    setState(() => isPaying = true);
    try {
      final success =
      await orderProvider.updatePaymentStatus(widget.order.sId!, "paid");
      if (success) {
        showCustomMessage(context, "Payment successful ✅");
        setState(() {
          widget.order.paymentStatus = "paid";
        });
      }
    } catch (e) {
      showCustomMessage(context, "Payment failed ❌");
    } finally {
      if (mounted) setState(() => isPaying = false);
    }
  }

  Future<void> cancelOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    setState(() => isUpdating = true);
    try {
      final success =
      await orderProvider.updateOrderStatus(widget.order.sId!, "canceled");
      if (success) {
        showCustomMessage(context, "Order canceled ✅");
        setState(() {
          widget.order.orderStatus = "canceled";
        });
      }
    } catch (e) {
      showCustomMessage(context, "Cancel failed ❌");
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  // --- Restyled Item Card ---
  Widget buildItemCard(Items item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.image ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child:
                  Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? "-",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Size: ${item.size ?? '-'} | Color: ${item.color ?? '-'}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Qty: ${item.quantity ?? 0}",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹${item.price?.toStringAsFixed(0) ?? '0'}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

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
      case "canceled":
      case "cancelled": // Handle both spellings
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Restyled Order Summary ---
            _buildSectionHeader("Order Summary"),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order Status",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                        Text(
                          order.orderStatus?.toUpperCase() ?? "-",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _getStatusColor(order.orderStatus)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Payment Status",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                        Text(
                          order.paymentStatus?.toUpperCase() ?? "-",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order Total",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                        Text(
                          "₹${order.total?.toStringAsFixed(0) ?? 0}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "ID: ${order.sId}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),

            // --- Items Section ---
            _buildSectionHeader(
                "Items (${order.items?.length ?? 0})"),
            ...?order.items?.map((item) => buildItemCard(item)),
            const SizedBox(height: 12),

            // --- Restyled Address Section ---
            _buildSectionHeader("Delivery Address"),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.grey[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.address != null
                            ? "${order.address!.label}\n${order.address!.street}, ${order.address!.city}, ${order.address!.state} ${order.address!.zip}, ${order.address!.country}"
                            : "No address found.",
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Restyled Action Buttons ---
            if (order.paymentStatus?.toLowerCase() != "paid" &&
                order.orderStatus?.toLowerCase() != "canceled" &&
                order.orderStatus?.toLowerCase() != "cancelled")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPaying ? null : payOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isPaying
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text("Pay Now"),
                ),
              ),
            const SizedBox(height: 12),
            if (order.orderStatus?.toLowerCase() == "pending")
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isUpdating ? null : cancelOrder,
                  child: isUpdating
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.red),
                  )
                      : const Text("Cancel Order"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}