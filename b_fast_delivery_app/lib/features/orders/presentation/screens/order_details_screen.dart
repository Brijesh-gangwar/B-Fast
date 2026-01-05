
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';

// // // // import '../../data/models/order_model.dart';
// // // // import '../view_model.dart/order_provider.dart';
// // // // import '../widgets/location_screen.dart';

// // // // class OrderDetailsScreen extends StatefulWidget {
// // // //   final OrderModel order;

// // // //   const OrderDetailsScreen({super.key, required this.order});

// // // //   @override
// // // //   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// // // // }

// // // // class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
// // // //   bool _isDeliveryLoading = false;
// // // //   bool _isPaymentLoading = false;

// // // //   // Determines the next delivery action based on the current status.
// // // //   Map<String, String>? _getDeliveryAction() {
// // // //     switch (widget.order.deliveryAgentStatus) {
// // // //       case "Assigned":
// // // //         return {"nextStatus": "Delivering", "buttonText": "Start Delivery"};
// // // //       case "Delivering":
// // // //         return {"nextStatus": "Delivered", "buttonText": "Mark as Delivered"};
// // // //       default:
// // // //         return null;
// // // //     }
// // // //   }

// // // //   // Handles updating the delivery agent status and the main order status.
// // // //   Future<void> _handleUpdateDeliveryStatus() async {
// // // //     final action = _getDeliveryAction();
// // // //     if (action == null) return;

// // // //     setState(() => _isDeliveryLoading = true);

// // // //     final orderId = widget.order.sId;
// // // //     final currentStatus = widget.order.deliveryAgentStatus;
// // // //     final newStatus = action["nextStatus"]!;

// // // //     if (orderId == null || currentStatus == null) {
// // // //       _showSnackBar("Error: Missing order information.", isError: true);
// // // //       setState(() => _isDeliveryLoading = false);
// // // //       return;
// // // //     }

// // // //     final success =
// // // //         await context.read<OrderProvider>().updateDeliveryAgentStatus(
// // // //               orderId: orderId,
// // // //               currentStatus: currentStatus,
// // // //               newStatus: newStatus,
// // // //             );

// // // //     if (success && newStatus == "Delivered") {
// // // //       context.read<OrderProvider>().updateMainOrderStatus(
// // // //             orderId: orderId,
// // // //             newOrderStatus: "Delivered",
// // // //           );
// // // //     }

// // // //     _showSnackBar(
// // // //       success
// // // //           ? "Delivery status updated successfully!"
// // // //           : "Failed to update delivery status.",
// // // //       isError: !success,
// // // //     );

// // // //     if (success && mounted) {
// // // //       Navigator.pop(context);
// // // //     } else {
// // // //       setState(() => _isDeliveryLoading = false);
// // // //     }
// // // //   }

// // // //   // Shows a dialog for the agent to select a new payment status.
// // // //   Future<void> _showPaymentStatusDialog() async {
// // // //     final List<String> options = ["Paid", "Failed"];

// // // //     final String? selectedStatus = await showDialog<String>(
// // // //       context: context,
// // // //       builder: (BuildContext context) {
// // // //         return SimpleDialog(
// // // //           title: const Text('Update Payment Status'),
// // // //           children: options.map((status) {
// // // //             return SimpleDialogOption(
// // // //               onPressed: () {
// // // //                 Navigator.pop(context, status); // Return the selected status
// // // //               },
// // // //               child: Text(status),
// // // //             );
// // // //           }).toList(),
// // // //         );
// // // //       },
// // // //     );

// // // //     if (selectedStatus != null) {
// // // //       await _handleUpdatePaymentStatus(selectedStatus);
// // // //     }
// // // //   }

// // // //   // Handles updating the payment status for COD orders.
// // // //   Future<void> _handleUpdatePaymentStatus(String newPaymentStatus) async {
// // // //     final orderId = widget.order.sId;
// // // //     if (orderId == null) {
// // // //       _showSnackBar("Error: Missing order information.", isError: true);
// // // //       return;
// // // //     }

// // // //     setState(() => _isPaymentLoading = true);

// // // //     final success = await context.read<OrderProvider>().updatePaymentStatus(
// // // //         orderId: orderId, newPaymentStatus: newPaymentStatus);

// // // //     _showSnackBar(
// // // //       success
// // // //           ? "Payment status updated to $newPaymentStatus!"
// // // //           : "Failed to update payment status.",
// // // //       isError: !success,
// // // //     );

// // // //     setState(() => _isPaymentLoading = false);
// // // //   }

// // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // //     if (mounted) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(
// // // //           content: Text(message),
// // // //           backgroundColor: isError ? Colors.red : Colors.green,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }
  
// // // //   // ✅ NEW HELPER: Finds the most up-to-date version of the order from the provider.
// // // //   OrderModel _findLatestOrder(BuildContext context) {
// // // //     final provider = context.watch<OrderProvider>();
// // // //     // Combine all order lists to search through them.
// // // //     final allOrders = [...provider.assignedOrders(), ...provider.deliveringOrders()];
    
// // // //     // Find the order with the matching ID.
// // // //     final index = allOrders.indexWhere((o) => o.sId == widget.order.sId);

// // // //     // If found, return the reactive order from the provider.
// // // //     // Otherwise, fall back to the initial order passed to the widget.
// // // //     return index != -1 ? allOrders[index] : widget.order;
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text("Order Details"),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             _buildOrderInfoSection(),
// // // //             const Divider(height: 32, thickness: 1),
// // // //             _buildPaymentSection(),
// // // //             const Divider(height: 32, thickness: 1),
// // // //             _buildAddressSection(),
// // // //             const Divider(height: 32, thickness: 1),
// // // //             _buildItemsSection(),
// // // //             const SizedBox(height: 24),
// // // //             widget.order.deliveryAgentStatus == "Delivering" &&
// // // //                     widget.order.paymentMethod == "Cash on Delivery" &&
// // // //                     widget.order.paymentStatus != "Paid"
// // // //                 ? const SizedBox.shrink()
// // // //                 : _buildActionButtons(),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // --- UI Helper Widgets ---

// // // //   Widget _buildOrderInfoSection() {
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Text(
// // // //           "Order ID: ${widget.order.orderId ?? 'N/A'}",
// // // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // //         ),
// // // //         const SizedBox(height: 8),
// // // //         Text("Agent Status: ${widget.order.deliveryAgentStatus ?? 'N/A'}"),
// // // //         Text("Order Status: ${widget.order.orderStatus ?? 'N/A'}"),
// // // //         Text("Delivery Mode: ${widget.order.deliveryMode ?? 'N/A'}"),
// // // //         Text("Estimated Time: ${widget.order.estimatedTime ?? 'N/A'}"),
// // // //       ],
// // // //     );
// // // //   }
  
// // // //   // ✅ UPDATED: This section is now fully reactive for all order types.
// // // //   Widget _buildPaymentSection() {
// // // //     // Use the helper to get the latest, reactive order data.
// // // //     final order = _findLatestOrder(context);
    
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         const Text(
// // // //           "Payment Details",
// // // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // // //         ),
// // // //         const SizedBox(height: 8),
// // // //         Text("Payment Method: ${order.paymentMethod ?? 'N/A'}"),
// // // //         Text("Payment Status: ${order.paymentStatus ?? 'N/A'}"),
// // // //         Text("Total Amount: ₹${order.total ?? 0}"),
        
// // // //         // This condition now works correctly for any order (Assigned, Delivering, etc.)
// // // //         if (order.deliveryAgentStatus == "Delivering" &&
// // // //           order.paymentMethod == "Cash on Delivery" &&
// // // //             order.paymentStatus != "Paid") ...[
// // // //           const SizedBox(height: 16),
// // // //           SizedBox(
// // // //             width: double.infinity,
// // // //             child: ElevatedButton(
// // // //               onPressed: _isPaymentLoading ? null : _showPaymentStatusDialog,
// // // //               style: ElevatedButton.styleFrom(
// // // //                 backgroundColor: Colors.green,
// // // //                 foregroundColor: Colors.white,
// // // //                 padding: const EdgeInsets.symmetric(vertical: 12),
// // // //               ),
// // // //               child: _isPaymentLoading
// // // //                   ? const SizedBox(
// // // //                       height: 20,
// // // //                       width: 20,
// // // //                       child: CircularProgressIndicator(
// // // //                           strokeWidth: 2, color: Colors.white))
// // // //                   : const Text("Update Payment Status"),
// // // //             ),
// // // //           )
// // // //         ],
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildAddressSection() {
// // // //     final address = widget.order.address;
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         const Text(
// // // //           "Delivery Address",
// // // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // // //         ),
// // // //         const SizedBox(height: 8),
// // // //         if (address != null) ...[
// // // //           Text("Street: ${address.street ?? 'N/A'}"),
// // // //           Text("City: ${address.city ?? 'N/A'}"),
// // // //           Text("State: ${address.state ?? 'N/A'}"),
// // // //           Text("ZIP: ${address.zip ?? 'N/A'}"),
// // // //           const SizedBox(height: 8),
// // // //           LocationButton(address: address)
// // // //         ],
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildItemsSection() {
// // // //     final items = widget.order.items ?? [];
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         const Text(
// // // //           "Items",
// // // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // // //         ),
// // // //         const SizedBox(height: 8),
// // // //         ...items.map((item) => Card(
// // // //               margin: const EdgeInsets.symmetric(vertical: 6),
// // // //               child: ListTile(
// // // //                 leading: item.image != null
// // // //                     ? Image.network(item.image!,
// // // //                         width: 50, height: 50, fit: BoxFit.cover)
// // // //                     : const Icon(Icons.image),
// // // //                 title: Text(item.name ?? 'Item'),
// // // //                 subtitle: Text("Quantity: ${item.quantity ?? 0}"),
// // // //                 trailing: Text("₹${item.price ?? 0}"),
// // // //               ),
// // // //             )),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildActionButtons() {
// // // //     final deliveryAction = _getDeliveryAction();
// // // //     if (deliveryAction == null) return const SizedBox.shrink();

// // // //     return SizedBox(
// // // //       width: double.infinity,
// // // //       child: ElevatedButton(
// // // //         onPressed: _isDeliveryLoading ? null : _handleUpdateDeliveryStatus,
// // // //         style: ElevatedButton.styleFrom(
// // // //           backgroundColor: Colors.black,
// // // //           foregroundColor: Colors.white,
// // // //           padding: const EdgeInsets.symmetric(vertical: 16),
// // // //           shape:
// // // //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // //         ),
// // // //         child: _isDeliveryLoading
// // // //             ? const SizedBox(
// // // //                 height: 20,
// // // //                 width: 20,
// // // //                 child: CircularProgressIndicator(
// // // //                     strokeWidth: 2, color: Colors.white))
// // // //             : Text(deliveryAction["buttonText"]!,
// // // //                 style: const TextStyle(fontSize: 16)),
// // // //       ),
// // // //     );
// // // //   }
// // // // }


// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';

// // // import '../../../profile/presentation/view_model/agent_details_provider.dart';
// // // import '../../data/models/order_model.dart';
// // // import '../view_model.dart/order_provider.dart';
// // // import '../widgets/location_screen.dart';

// // // class OrderDetailsScreen extends StatefulWidget {
// // //   final OrderModel order;

// // //   const OrderDetailsScreen({super.key, required this.order});

// // //   @override
// // //   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// // // }

// // // class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
// // //   bool _isDeliveryLoading = false;
// // //   bool _isPaymentLoading = false;

// // //   // Determines the next delivery action based on the current status.
// // //   Map<String, String>? _getDeliveryAction() {
// // //     switch (widget.order.deliveryAgentStatus) {
// // //       case "Assigned":
// // //         return {"nextStatus": "Delivering", "buttonText": "Start Delivery"};
// // //       case "Delivering":
// // //         return {"nextStatus": "Delivered", "buttonText": "Mark as Delivered"};
// // //       default:
// // //         return null;
// // //     }
// // //   }

// // //   // Handles updating the delivery agent status and the main order status.
// // //   Future<void> _handleUpdateDeliveryStatus() async {
// // //     final action = _getDeliveryAction();
// // //     if (action == null) return;

// // //     setState(() => _isDeliveryLoading = true);

// // //     final orderId = widget.order.sId;
// // //     final currentStatus = widget.order.deliveryAgentStatus;
// // //     final newStatus = action["nextStatus"]!;

// // //     if (orderId == null || currentStatus == null) {
// // //       _showSnackBar("Error: Missing order information.", isError: true);
// // //       setState(() => _isDeliveryLoading = false);
// // //       return;
// // //     }

// // //     final success =
// // //         await context.read<OrderProvider>().updateDeliveryAgentStatus(
// // //               orderId: orderId,
// // //               currentStatus: currentStatus,
// // //               newStatus: newStatus,
// // //             );

// // //     if (success && newStatus == "Delivered") {
// // //       // Also update the main order status in the backend
// // //       context.read<OrderProvider>().updateMainOrderStatus(
// // //             orderId: orderId,
// // //             newOrderStatus: "Delivered",
// // //           );
      
// // //       // ✅ ADDED: Increment the delivery count in the UI
// // //       context.read<AgentDetailsProvider>().incrementDeliveries();
// // //     }

// // //     _showSnackBar(
// // //       success
// // //           ? "Delivery status updated successfully!"
// // //           : "Failed to update delivery status.",
// // //       isError: !success,
// // //     );

// // //     if (success && mounted) {
// // //       Navigator.pop(context);
// // //     } else {
// // //       setState(() => _isDeliveryLoading = false);
// // //     }
// // //   }

// // //   // Shows a dialog for the agent to select a new payment status.
// // //   Future<void> _showPaymentStatusDialog() async {
// // //     // ✅ UPDATED: Options are now "Paid" and "Failed"
// // //     final List<String> options = ["Paid", "Failed"];

// // //     final String? selectedStatus = await showDialog<String>(
// // //       context: context,
// // //       builder: (BuildContext context) {
// // //         return SimpleDialog(
// // //           title: const Text('Update Payment Status'),
// // //           children: options.map((status) {
// // //             return SimpleDialogOption(
// // //               onPressed: () {
// // //                 Navigator.pop(context, status);
// // //               },
// // //               child: Text(status),
// // //             );
// // //           }).toList(),
// // //         );
// // //       },
// // //     );

// // //     if (selectedStatus != null) {
// // //       await _handleUpdatePaymentStatus(selectedStatus);
// // //     }
// // //   }

// // //   // Handles updating the payment status for COD orders.
// // //   Future<void> _handleUpdatePaymentStatus(String newPaymentStatus) async {
// // //     final orderId = widget.order.sId;
// // //     if (orderId == null) {
// // //       _showSnackBar("Error: Missing order information.", isError: true);
// // //       return;
// // //     }

// // //     setState(() => _isPaymentLoading = true);

// // //     final success = await context.read<OrderProvider>().updatePaymentStatus(
// // //         orderId: orderId, newPaymentStatus: newPaymentStatus);

// // //     _showSnackBar(
// // //       success
// // //           ? "Payment status updated to $newPaymentStatus!"
// // //           : "Failed to update payment status.",
// // //       isError: !success,
// // //     );

// // //     setState(() => _isPaymentLoading = false);
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text(message),
// // //           backgroundColor: isError ? Colors.red : Colors.green,
// // //         ),
// // //       );
// // //     }
// // //   }
  
// // //   // Helper to find the most up-to-date version of the order from the provider.
// // //   OrderModel _findLatestOrder(BuildContext context) {
// // //     final provider = context.watch<OrderProvider>();
// // //     final allOrders = [...provider.assignedOrders(), ...provider.deliveringOrders()];
    
// // //     final index = allOrders.indexWhere((o) => o.sId == widget.order.sId);

// // //     return index != -1 ? allOrders[index] : widget.order;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Get the latest reactive version of the order
// // //     final order = _findLatestOrder(context);

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text("Order Details"),
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             _buildOrderInfoSection(order),
// // //             const Divider(height: 32, thickness: 1),
// // //             _buildPaymentSection(order),
// // //             const Divider(height: 32, thickness: 1),
// // //             _buildAddressSection(order),
// // //             const Divider(height: 32, thickness: 1),
// // //             _buildItemsSection(order),
// // //             const SizedBox(height: 24),

// // //             // ✅ NEW LOGIC: Conditionally show the delivery action button.
// // //             // It will be hidden for pending COD orders that are being delivered.
// // //             if (order.deliveryAgentStatus == "Delivering" &&
// // //                 order.paymentMethod == "Cash on Delivery" &&
// // //                 order.paymentStatus != "Paid")
// // //               const SizedBox.shrink() // Hide the button
// // //             else
// // //               _buildActionButtons(), // Show the button
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // --- UI Helper Widgets ---

// // //   Widget _buildOrderInfoSection(OrderModel order) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           "Order ID: ${order.orderId ?? 'N/A'}",
// // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //         ),
// // //         const SizedBox(height: 8),
// // //         Text("Agent Status: ${order.deliveryAgentStatus ?? 'N/A'}"),
// // //         Text("Order Status: ${order.orderStatus ?? 'N/A'}"),
// // //         Text("Delivery Mode: ${order.deliveryMode ?? 'N/A'}"),
// // //         Text("Estimated Time: ${order.estimatedTime ?? 'N/A'}"),
// // //       ],
// // //     );
// // //   }
  
// // //   Widget _buildPaymentSection(OrderModel order) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         const Text(
// // //           "Payment Details",
// // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //         ),
// // //         const SizedBox(height: 8),
// // //         Text("Payment Method: ${order.paymentMethod ?? 'N/A'}"),
// // //         Text("Payment Status: ${order.paymentStatus ?? 'N/A'}"),
// // //         Text("Total Amount: ₹${order.total ?? 0}"),
        
// // //         // ✅ UPDATED: Condition is more specific to "Pending"
// // //         if (order.paymentMethod == "Cash on Delivery" &&
// // //             order.paymentStatus == "Pending") ...[
// // //           const SizedBox(height: 16),
// // //           SizedBox(
// // //             width: double.infinity,
// // //             child: ElevatedButton(
// // //               onPressed: _isPaymentLoading ? null : _showPaymentStatusDialog,
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: Colors.green,
// // //                 foregroundColor: Colors.white,
// // //                 padding: const EdgeInsets.symmetric(vertical: 12),
// // //               ),
// // //               child: _isPaymentLoading
// // //                   ? const SizedBox(
// // //                       height: 20,
// // //                       width: 20,
// // //                       child: CircularProgressIndicator(
// // //                           strokeWidth: 2, color: Colors.white))
// // //                   : const Text("Update Payment Status"),
// // //             ),
// // //           )
// // //         ],
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildAddressSection(OrderModel order) {
// // //     final address = order.address;
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         const Text(
// // //           "Delivery Address",
// // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //         ),
// // //         const SizedBox(height: 8),
// // //         if (address != null) ...[
// // //           Text("Street: ${address.street ?? 'N/A'}"),
// // //           Text("City: ${address.city ?? 'N/A'}"),
// // //           Text("State: ${address.state ?? 'N/A'}"),
// // //           Text("ZIP: ${address.zip ?? 'N/A'}"),
// // //           const SizedBox(height: 8),
// // //           LocationButton(address: address)
// // //         ],
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildItemsSection(OrderModel order) {
// // //     final items = order.items ?? [];
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         const Text(
// // //           "Items",
// // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //         ),
// // //         const SizedBox(height: 8),
// // //         ...items.map((item) => Card(
// // //               margin: const EdgeInsets.symmetric(vertical: 6),
// // //               child: ListTile(
// // //                 leading: item.image != null
// // //                     ? Image.network(item.image!,
// // //                         width: 50, height: 50, fit: BoxFit.cover)
// // //                     : const Icon(Icons.image),
// // //                 title: Text(item.name ?? 'Item'),
// // //                 subtitle: Text("Quantity: ${item.quantity ?? 0}"),
// // //                 trailing: Text("₹${item.price ?? 0}"),
// // //               ),
// // //             )),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildActionButtons() {
// // //     final deliveryAction = _getDeliveryAction();
// // //     if (deliveryAction == null) return const SizedBox.shrink();

// // //     return SizedBox(
// // //       width: double.infinity,
// // //       child: ElevatedButton(
// // //         onPressed: _isDeliveryLoading ? null : _handleUpdateDeliveryStatus,
// // //         style: ElevatedButton.styleFrom(
// // //           backgroundColor: Colors.black,
// // //           foregroundColor: Colors.white,
// // //           padding: const EdgeInsets.symmetric(vertical: 16),
// // //           shape:
// // //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //         ),
// // //         child: _isDeliveryLoading
// // //             ? const SizedBox(
// // //                 height: 20,
// // //                 width: 20,
// // //                 child: CircularProgressIndicator(
// // //                     strokeWidth: 2, color: Colors.white))
// // //             : Text(deliveryAction["buttonText"]!,
// // //                 style: const TextStyle(fontSize: 16)),
// // //       ),
// // //     );
// // //   }
// // // }


// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // import '../../../profile/presentation/view_model/agent_details_provider.dart';
// // import '../../data/models/order_model.dart';
// // import '../view_model.dart/order_provider.dart';
// // import '../widgets/location_screen.dart';

// // class OrderDetailsScreen extends StatefulWidget {
// //   final OrderModel order;

// //   const OrderDetailsScreen({super.key, required this.order});

// //   @override
// //   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// // }

// // class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
// //   bool _isDeliveryLoading = false;
// //   bool _isPaymentLoading = false;

// //   // Determines the next delivery action based on the current status.
// //   Map<String, String>? _getDeliveryAction() {
// //     switch (widget.order.deliveryAgentStatus) {
// //       case "Assigned":
// //         return {"nextStatus": "Delivering", "buttonText": "Start Delivery"};
// //       case "Delivering":
// //         return {"nextStatus": "Delivered", "buttonText": "Mark as Delivered"};
// //       default:
// //         return null;
// //     }
// //   }

// //   // Handles updating the delivery agent status and the main order status.
// //   Future<void> _handleUpdateDeliveryStatus() async {
// //     final action = _getDeliveryAction();
// //     if (action == null) return;

// //     setState(() => _isDeliveryLoading = true);

// //     final orderId = widget.order.sId;
// //     final currentStatus = widget.order.deliveryAgentStatus;
// //     final newStatus = action["nextStatus"]!;

// //     if (orderId == null || currentStatus == null) {
// //       _showSnackBar("Error: Missing order information.", isError: true);
// //       setState(() => _isDeliveryLoading = false);
// //       return;
// //     }

// //     final success =
// //         await context.read<OrderProvider>().updateDeliveryAgentStatus(
// //               orderId: orderId,
// //               currentStatus: currentStatus,
// //               newStatus: newStatus,
// //             );

// //     if (success && newStatus == "Delivered") {
// //       // Also update the main order status in the backend
// //       context.read<OrderProvider>().updateMainOrderStatus(
// //             orderId: orderId,
// //             newOrderStatus: "Delivered",
// //           );

// //       // ✅ ADDED: Increment the delivery count in the UI
// //       context.read<AgentDetailsProvider>().incrementDeliveries();
// //     }

// //     _showSnackBar(
// //       success
// //           ? "Delivery status updated successfully!"
// //           : "Failed to update delivery status.",
// //       isError: !success,
// //     );

// //     if (success && mounted) {
// //       Navigator.pop(context);
// //     } else {
// //       setState(() => _isDeliveryLoading = false);
// //     }
// //   }

// //   // Shows a dialog for the agent to select a new payment status.
// //   Future<void> _showPaymentStatusDialog() async {
// //     // ✅ UPDATED: Options are now "Paid" and "Failed"
// //     final List<String> options = ["Paid", "Failed"];

// //     final String? selectedStatus = await showDialog<String>(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return SimpleDialog(
// //           title: const Text('Update Payment Status'),
// //           children: options.map((status) {
// //             return SimpleDialogOption(
// //               onPressed: () {
// //                 Navigator.pop(context, status);
// //               },
// //               child: Text(status),
// //             );
// //           }).toList(),
// //         );
// //       },
// //     );

// //     if (selectedStatus != null) {
// //       await _handleUpdatePaymentStatus(selectedStatus);
// //     }
// //   }

// //   // Handles updating the payment status for COD orders.
// //   Future<void> _handleUpdatePaymentStatus(String newPaymentStatus) async {
// //     final orderId = widget.order.sId;
// //     if (orderId == null) {
// //       _showSnackBar("Error: Missing order information.", isError: true);
// //       return;
// //     }

// //     setState(() => _isPaymentLoading = true);

// //     final success = await context.read<OrderProvider>().updatePaymentStatus(
// //         orderId: orderId, newPaymentStatus: newPaymentStatus);

// //     _showSnackBar(
// //       success
// //           ? "Payment status updated to $newPaymentStatus!"
// //           : "Failed to update payment status.",
// //       isError: !success,
// //     );

// //     setState(() => _isPaymentLoading = false);
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: isError ? Colors.red : Colors.green,
// //         ),
// //       );
// //     }
// //   }

// //   // Helper to find the most up-to-date version of the order from the provider.
// //   OrderModel _findLatestOrder(BuildContext context) {
// //     final provider = context.watch<OrderProvider>();
// //     final allOrders = [
// //       ...provider.assignedOrders(),
// //       ...provider.deliveringOrders()
// //     ];

// //     final index = allOrders.indexWhere((o) => o.sId == widget.order.sId);

// //     return index != -1 ? allOrders[index] : widget.order;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get the latest reactive version of the order
// //     final order = _findLatestOrder(context);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Order Details"),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           // ✅ FIX: This makes all children (Cards) fill the width
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             _buildOrderInfoSection(order),
// //             const SizedBox(height: 16), // Replaced Divider
// //             _buildPaymentSection(order),
// //             const SizedBox(height: 16), // Replaced Divider
// //             _buildAddressSection(order),
// //             const SizedBox(height: 16), // Replaced Divider
// //             _buildItemsSection(order),
// //             const SizedBox(height: 24),

// //             // ✅ NEW LOGIC: Conditionally show the delivery action button.
// //             // It will be hidden for pending COD orders that are being delivered.
// //             if (order.deliveryAgentStatus == "Delivering" &&
// //                 order.paymentMethod == "Cash on Delivery" &&
// //                 order.paymentStatus != "Paid")
// //               const SizedBox.shrink() // Hide the button
// //             else
// //               _buildActionButtons(), // Show the button
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // --- UI Helper Widgets ---

// //   // ✅ UI: Wrapped in Card
// //   Widget _buildOrderInfoSection(OrderModel order) {
// //     return Card(
// //       elevation: 2,
// //       clipBehavior: Clip.antiAlias,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
// //           children: [
// //             Text(
// //               "Order ID: ${order.orderId ?? 'N/A'}",
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             Text("Agent Status: ${order.deliveryAgentStatus ?? 'N/A'}"),
// //             Text("Order Status: ${order.orderStatus ?? 'N/A'}"),
// //             Text("Delivery Mode: ${order.deliveryMode ?? 'N/A'}"),
// //             Text("Estimated Time: ${order.estimatedTime ?? 'N/A'}"),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ✅ UI: Wrapped in Card
// //   Widget _buildPaymentSection(OrderModel order) {
// //     return Card(
// //       elevation: 2,
// //       clipBehavior: Clip.antiAlias,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
// //           children: [
// //             const Text(
// //               "Payment Details",
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             Text("Payment Method: ${order.paymentMethod ?? 'N/A'}"),
// //             Text("Payment Status: ${order.paymentStatus ?? 'N/A'}"),
// //             Text("Total Amount: ₹${order.total ?? 0}"),

// //             // ✅ UPDATED: Condition is more specific to "Pending"
// //             if (order.paymentMethod == "Cash on Delivery" &&
// //                 order.paymentStatus == "Pending") ...[
// //               const SizedBox(height: 16),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   onPressed: _isPaymentLoading ? null : _showPaymentStatusDialog,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     foregroundColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(vertical: 12),
// //                   ),
// //                   child: _isPaymentLoading
// //                       ? const SizedBox(
// //                           height: 20,
// //                           width: 20,
// //                           child: CircularProgressIndicator(
// //                               strokeWidth: 2, color: Colors.white))
// //                       : const Text("Update Payment Status"),
// //                 ),
// //               )
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ✅ UI: Wrapped in Card
// //   Widget _buildAddressSection(OrderModel order) {
// //     final address = order.address;
// //     return Card(
// //       elevation: 2,
// //       clipBehavior: Clip.antiAlias,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
// //           children: [
// //             const Text(
// //               "Delivery Address",
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             if (address != null) ...[
// //               Text("Street: ${address.street ?? 'N/A'}"),
// //               Text("City: ${address.city ?? 'N/A'}"),
// //               Text("State: ${address.state ?? 'N/A'}"),
// //               Text("ZIP: ${address.zip ?? 'N/A'}"),
// //               const SizedBox(height: 8),
// //               LocationButton(address: address)
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ✅ UI: Wrapped in Card (Note: This will create a nested Card structure)
// //   Widget _buildItemsSection(OrderModel order) {
// //     final items = order.items ?? [];
// //     return Card(
// //       elevation: 2,
// //       clipBehavior: Clip.antiAlias,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
// //           children: [
// //             const Text(
// //               "Items",
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             ...items.map((item) => Card(
// //                   margin: const EdgeInsets.symmetric(vertical: 6),
// //                   child: ListTile(
// //                     leading: item.image != null
// //                         ? Image.network(item.image!,
// //                             width: 50, height: 50, fit: BoxFit.cover)
// //                         : const Icon(Icons.image),
// //                     title: Text(item.name ?? 'Item'),
// //                     subtitle: Text("Quantity: ${item.quantity ?? 0}"),
// //                     trailing: Text("₹${item.price ?? 0}"),
// //                   ),
// //                 )),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildActionButtons() {
// //     final deliveryAction = _getDeliveryAction();
// //     if (deliveryAction == null) return const SizedBox.shrink();

// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _isDeliveryLoading ? null : _handleUpdateDeliveryStatus,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.black,
// //           foregroundColor: Colors.white,
// //           padding: const EdgeInsets.symmetric(vertical: 16),
// //           shape:
// //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         ),
// //         child: _isDeliveryLoading
// //             ? const SizedBox(
// //                 height: 20,
// //                 width: 20,
// //                 child: CircularProgressIndicator(
// //                     strokeWidth: 2, color: Colors.white))
// //             : Text(deliveryAction["buttonText"]!,
// //                 style: const TextStyle(fontSize: 16)),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../profile/presentation/view_model/agent_details_provider.dart';
// import '../../data/models/order_model.dart';
// import '../view_model.dart/order_provider.dart';
// import '../widgets/location_screen.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   final OrderModel order;

//   const OrderDetailsScreen({super.key, required this.order});

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   bool _isDeliveryLoading = false;
//   bool _isPaymentLoading = false;
//   bool _isCancelling = false; // ✅ ADDED: State for cancel button

//   // Determines the next delivery action based on the current status.
//   Map<String, String>? _getDeliveryAction() {
//     switch (widget.order.deliveryAgentStatus) {
//       case "Assigned":
//         return {"nextStatus": "Delivering", "buttonText": "Start Delivery"};
//       case "Delivering":
//         return {"nextStatus": "Delivered", "buttonText": "Mark as Delivered"};
//       default:
//         return null;
//     }
//   }

//   // Handles updating the delivery agent status and the main order status.
//   Future<void> _handleUpdateDeliveryStatus() async {
//     final action = _getDeliveryAction();
//     if (action == null) return;

//     setState(() => _isDeliveryLoading = true);

//     final orderId = widget.order.sId;
//     final currentStatus = widget.order.deliveryAgentStatus;
//     final newStatus = action["nextStatus"]!;

//     if (orderId == null || currentStatus == null) {
//       _showSnackBar("Error: Missing order information.", isError: true);
//       setState(() => _isDeliveryLoading = false);
//       return;
//     }

//     final success =
//         await context.read<OrderProvider>().updateDeliveryAgentStatus(
//               orderId: orderId,
//               currentStatus: currentStatus,
//               newStatus: newStatus,
//             );

//     if (success && newStatus == "Delivered") {
//       // Also update the main order status in the backend
//       context.read<OrderProvider>().updateMainOrderStatus(
//             orderId: orderId,
//             newOrderStatus: "Delivered",
//           );

//       // ✅ ADDED: Increment the delivery count in the UI
//       context.read<AgentDetailsProvider>().incrementDeliveries();
//     }

//     _showSnackBar(
//       success
//           ? "Delivery status updated successfully!"
//           : "Failed to update delivery status.",
//       isError: !success,
//     );

//     if (success && mounted) {
//       Navigator.pop(context);
//     } else {
//       setState(() => _isDeliveryLoading = false);
//     }
//   }

//   // ✅ ADDED: Handles cancelling the order
//   Future<void> _handleCancelOrder() async {
//     setState(() => _isCancelling = true);

//     final orderId = widget.order.sId;
//     if (orderId == null) {
//       _showSnackBar("Error: Missing order information.", isError: true);
//       setState(() => _isCancelling = false);
//       return;
//     }

//     // 1. Update the Agent's status first
//     final agentStatusSuccess =
//         await context.read<OrderProvider>().updateDeliveryAgentStatus(
//               orderId: orderId,
//               currentStatus:
//                   "Delivering", // We know this from the button's condition
//               newStatus: "Delivered", // The new agent status
//             );

//     bool mainStatusSuccess = false;
//     if (agentStatusSuccess) {
//       // 2. If that succeeds, update the main order status
//       mainStatusSuccess =
//           await context.read<OrderProvider>().updateMainOrderStatus(
//                 orderId: orderId,
//                 newOrderStatus: "Cancelled", // The new main order status
//               );
//     }

//     // We'll consider it a full success only if both succeed
//     final bool success = agentStatusSuccess && mainStatusSuccess;

//     _showSnackBar(
//       success ? "Order cancelled successfully!" : "Failed to cancel order.",
//       isError: !success,
//     );

//     if (success && mounted) {
//       Navigator.pop(context);
//     } else {
//       setState(() => _isCancelling = false);
//     }
//   }

//   // Shows a dialog for the agent to select a new payment status.
//   Future<void> _showPaymentStatusDialog() async {
//     // ✅ UPDATED: Options are now "Paid" and "Failed"
//     final List<String> options = ["Paid", "Failed"];

//     final String? selectedStatus = await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           title: const Text('Update Payment Status'),
//           children: options.map((status) {
//             return SimpleDialogOption(
//               onPressed: () {
//                 Navigator.pop(context, status);
//               },
//               child: Text(status),
//             );
//           }).toList(),
//         );
//       },
//     );

//     if (selectedStatus != null) {
//       await _handleUpdatePaymentStatus(selectedStatus);
//     }
//   }

//   // Handles updating the payment status for COD orders.
//   Future<void> _handleUpdatePaymentStatus(String newPaymentStatus) async {
//     final orderId = widget.order.sId;
//     if (orderId == null) {
//       _showSnackBar("Error: Missing order information.", isError: true);
//       return;
//     }

//     setState(() => _isPaymentLoading = true);

//     final success = await context.read<OrderProvider>().updatePaymentStatus(
//         orderId: orderId, newPaymentStatus: newPaymentStatus);

//     _showSnackBar(
//       success
//           ? "Payment status updated to $newPaymentStatus!"
//           : "Failed to update payment status.",
//       isError: !success,
//     );

//     setState(() => _isPaymentLoading = false);
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//         ),
//       );
//     }
//   }

//   // Helper to find the most up-to-date version of the order from the provider.
//   OrderModel _findLatestOrder(BuildContext context) {
//     final provider = context.watch<OrderProvider>();
//     final allOrders = [
//       ...provider.assignedOrders(),
//       ...provider.deliveringOrders()
//     ];

//     final index = allOrders.indexWhere((o) => o.sId == widget.order.sId);

//     return index != -1 ? allOrders[index] : widget.order;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the latest reactive version of the order
//     final order = _findLatestOrder(context);

//     return Scaffold(
//       backgroundColor:  Colors.white, // Light background for better contrast
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text("Order Details"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           // ✅ FIX: This makes all children (Cards) fill the width
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildOrderInfoSection(order),
//             const SizedBox(height: 16),
//             _buildItemsSection(order),
//             const SizedBox(height: 16), // Replaced Divider
//             _buildAddressSection(order),
//             const SizedBox(height: 16), // Replaced Divider
//             _buildPaymentSection(order),            
//             const SizedBox(height: 24),

//             // --- Primary Action Button ---
//             if (order.deliveryAgentStatus == "Delivering" &&
//                 order.paymentMethod == "Cash on Delivery" &&
//                 order.paymentStatus != "Paid")
//               const SizedBox.shrink() // Hide the button
//             else
//               _buildActionButtons(), // Show the button

//             // --- ✅ ADDED: Cancel Button ---
//             // Only show if the order is currently being delivered
//             if (order.deliveryAgentStatus == "Delivering") ...[
//               const SizedBox(height: 12), // Space between buttons
//               _buildCancelButton(), // Show the new cancel button
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // --- UI Helper Widgets ---

//   // ✅ UI: Wrapped in Card
//   Widget _buildOrderInfoSection(OrderModel order) {
//     return Card(
//       elevation: 2,
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
//           children: [
//             Text(
//               "Order ID: ${order.orderId ?? 'N/A'}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text("Agent Status: ${order.deliveryAgentStatus ?? 'N/A'}"),
//             Text("Order Status: ${order.orderStatus ?? 'N/A'}"),
//             Text("Delivery Mode: ${order.deliveryMode ?? 'N/A'}"),
//             Text("Estimated Time: ${order.estimatedTime ?? 'N/A'}"),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ UI: Wrapped in Card


//   // ✅ UI: Wrapped in Card
//   Widget _buildPaymentSection(OrderModel order) {
//     return Card(
//       elevation: 2,
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
//           children: [
//             const Text(
//               "Payment Details",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text("Payment Method: ${order.paymentMethod ?? 'N/A'}"),
//             Text("Payment Status: ${order.paymentStatus ?? 'N/A'}"),
//             Text("Total Amount: ₹${order.total ?? 0}"),

//             // ✅ UPDATED: Condition now also checks if agent status is "Delivering"
//             if (order.paymentMethod == "Cash on Delivery" &&
//                 order.paymentStatus == "Pending" &&
//                 order.deliveryAgentStatus == "Delivering") ...[
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isPaymentLoading ? null : _showPaymentStatusDialog,
//                   style: ElevatedButton.styleFrom(
//                     // Changed to green as per your previous code
//                     backgroundColor: Colors.black, 
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: _isPaymentLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white))
//                       : const Text("Update Payment Status"),
//                 ),
//               )
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ UI: Wrapped in Card



//   Widget _buildAddressSection(OrderModel order) {
//     final address = order.address;
    
//     // Use Theme.of(context) for consistent styling
//     final textTheme = Theme.of(context).textTheme;

//     return Card(
//       elevation: 2,
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, 
//           children: [
//             // --- Title ---
//             Text(
//               "Delivery Address",
//               style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             // --- Content ---
//             if (address != null)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // --- Column 1: Address Text ---
//                   Expanded(
//                     child: Text(
//                       // Formatted as a real address block
//                       "${address.street ?? 'N/A'}\n${address.city ?? 'N/A'}, ${address.state ?? 'N/A'} ${address.zip ?? 'N/A'}",
//                       style: const TextStyle(fontSize: 14, height: 1.5),
//                     ),
//                   ),
//                   const SizedBox(width: 16), // Gutter

//                   // --- Column 2: Location Button ---
//                   // This assumes your LocationButton is an IconButton or small.
//                   LocationButton(address: address),
//                 ],
//               )
//             else
//               const Text("No address provided."), // Fallback
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ UI: Wrapped in Card (Note: This will create a nested Card structure)
//   Widget _buildItemsSection(OrderModel order) {
//     final items = order.items ?? [];
//     return Card(
//       elevation: 2,
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, // Keep text left-aligned
//           children: [
//             const Text(
//               "Items",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...items.map((item) => Card(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   child: ListTile(
//                     leading: item.image != null
//                         ? Image.network(item.image!,
//                             width: 50, height: 50, fit: BoxFit.cover)
//                         : const Icon(Icons.image),
//                     title: Text(item.name ?? 'Item'),
//                     subtitle: Text("Quantity: ${item.quantity ?? 0}"),
//                     trailing: Text("₹${item.price ?? 0}"),
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   // This is the PRIMARY action button (Start, Mark Delivered)
//   Widget _buildActionButtons() {
//     final deliveryAction = _getDeliveryAction();
//     if (deliveryAction == null) return const SizedBox.shrink();

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isDeliveryLoading ? null : _handleUpdateDeliveryStatus,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.black,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         child: _isDeliveryLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2, color: Colors.white))
//             : Text(deliveryAction["buttonText"]!,
//                 style: const TextStyle(fontSize: 16)),
//       ),
//     );
//   }

//   // ✅ ADDED: This is the new SECONDARY cancel button
//   Widget _buildCancelButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isCancelling ? null : _handleCancelOrder,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red.shade700, // Destructive action color
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         child: _isCancelling
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2, color: Colors.white))
//             : const Text("Cancel Order", style: TextStyle(fontSize: 16)),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/helpers/snackbar_fxn.dart';
import '../../../profile/presentation/view_model/agent_details_provider.dart';
import '../../data/models/order_model.dart';
import '../view_model.dart/order_provider.dart';
import '../widgets/location_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isDeliveryLoading = false;
  bool _isPaymentLoading = false;
  bool _isCancelling = false;

  Map<String, String>? _getDeliveryAction() {
    switch (widget.order.deliveryAgentStatus) {
      case "Assigned":
        return {"nextStatus": "Delivering", "buttonText": "Start Delivery"};
      case "Delivering":
        return {"nextStatus": "Delivered", "buttonText": "Mark as Delivered"};
      default:
        return null;
    }
  }

  Future<void> _handleUpdateDeliveryStatus() async {
    final action = _getDeliveryAction();
    if (action == null) return;

    setState(() => _isDeliveryLoading = true);

    final orderId = widget.order.sId;
    final currentStatus = widget.order.deliveryAgentStatus;
    final newStatus = action["nextStatus"]!;

    if (orderId == null || currentStatus == null) {
      _showSnackBar("Error: Missing order information.", isError: true);
      setState(() => _isDeliveryLoading = false);
      return;
    }

    final success =
        await context.read<OrderProvider>().updateDeliveryAgentStatus(
              orderId: orderId,
              currentStatus: currentStatus,
              newStatus: newStatus,
            );

    if (success && newStatus == "Delivered") {
      context.read<OrderProvider>().updateMainOrderStatus(
            orderId: orderId,
            newOrderStatus: "Delivered",
          );
      context.read<AgentDetailsProvider>().incrementDeliveries();
    }

    _showSnackBar(
      success
          ? "Delivery status updated successfully!"
          : "Failed to update delivery status.",
      isError: !success,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _isDeliveryLoading = false);
    }
  }

  Future<void> _handleCancelOrder() async {
    setState(() => _isCancelling = true);

    final orderId = widget.order.sId;
    if (orderId == null) {
      _showSnackBar("Error: Missing order information.", isError: true);
      setState(() => _isCancelling = false);
      return;
    }

    final agentStatusSuccess =
        await context.read<OrderProvider>().updateDeliveryAgentStatus(
              orderId: orderId,
              currentStatus: "Delivering",
              newStatus: "Delivered",
            );

    bool mainStatusSuccess = false;
    if (agentStatusSuccess) {
      mainStatusSuccess =
          await context.read<OrderProvider>().updateMainOrderStatus(
                orderId: orderId,
                newOrderStatus: "Cancelled",
              );
    }

    final bool success = agentStatusSuccess && mainStatusSuccess;

    _showSnackBar(
      success ? "Order cancelled successfully!" : "Failed to cancel order.",
      isError: !success,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _isCancelling = false);
    }
  }

  // Future<void> _showPaymentStatusDialog() async {
  //   final List<String> options = ["Paid", "Failed"];

  //   final String? selectedStatus = await showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         title: const Text('Update Payment Status'),
  //         children: options.map((status) {
  //           return SimpleDialogOption(
  //             onPressed: () {
  //               Navigator.pop(context, status);
  //             },
  //             child: Text(status),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );

  //   if (selectedStatus != null) {
  //     await _handleUpdatePaymentStatus(selectedStatus);
  //   }
  // }

  Future<void> _showPaymentStatusDialog() async {
  final List<String> options = ["Paid", "Failed"];

  final String? selectedStatus = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        title: const Text(
          'Update Payment Status',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          // Options as monochrome pills
          ...options.map((status) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context, status),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status == "Paid"
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Divider spacing
          const SizedBox(height: 4),

          // Cancel/Close action in monochrome
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      );
    },
  );

  if (selectedStatus != null) {
    await _handleUpdatePaymentStatus(selectedStatus);
  }
}

  Future<void> _handleUpdatePaymentStatus(String newPaymentStatus) async {
    final orderId = widget.order.sId;
    if (orderId == null) {
      _showSnackBar("Error: Missing order information.", isError: true);
      return;
    }

    setState(() => _isPaymentLoading = true);

    final success = await context
        .read<OrderProvider>()
        .updatePaymentStatus(orderId: orderId, newPaymentStatus: newPaymentStatus);

    _showSnackBar(
      success
          ? "Payment status updated to $newPaymentStatus!"
          : "Failed to update payment status.",
      isError: !success,
    );

    setState(() => _isPaymentLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {

      showCustomMessage(context, message);
      
    }
  }

  OrderModel _findLatestOrder(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final allOrders = [
      ...provider.assignedOrders(),
      ...provider.deliveringOrders()
    ];
    final index = allOrders.indexWhere((o) => o.sId == widget.order.sId);
    return index != -1 ? allOrders[index] : widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final order = _findLatestOrder(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Order Details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          _SectionCard(
            child: _HeaderFacts(order: order),
          ),
          _SectionCard(
            child: _ItemsSection(order: order),
          ),
          _SectionCard(
            child: _AddressSection(order: order),
          ),
          _SectionCard(
            child: _StoreAddressSection(order: order),
          ),
          _SectionCard(
            child: _PaymentSection(
              order: order,
              isPaymentLoading: _isPaymentLoading,
              onUpdatePayment: _showPaymentStatusDialog,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                _PrimaryButton(
                  loading: _isDeliveryLoading,
                  label: _getDeliveryAction()?["buttonText"],
                  onPressed: (_getDeliveryAction() == null ||
                          (order.deliveryAgentStatus == "Delivering" &&
                              order.paymentMethod == "Cash on Delivery" &&
                              order.paymentStatus != "Paid"))
                      ? null
                      : _handleUpdateDeliveryStatus,
                ),
                const SizedBox(height: 12),
                if (order.deliveryAgentStatus == "Delivering")
                  _DestructiveButton(
                    loading: _isCancelling,
                    label: "Cancel Order",
                    onPressed: _handleCancelOrder,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Monochrome primitives used on the details screen ----------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label!, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text("Cancel Order", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

// ---------- Section contents ----------

class _HeaderFacts extends StatelessWidget {
  const _HeaderFacts({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final id = order.orderId ?? 'N/A';
    final agentStatus = order.deliveryAgentStatus ?? 'N/A';
    final orderStatus = order.orderStatus ?? 'N/A';
    final mode = order.deliveryMode ?? 'N/A';
    final eta = order.estimatedTime ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Overview"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FactPill(icon: Icons.tag_outlined, label: 'ID: $id'),
            _FactPill(icon: Icons.badge_outlined, label: 'Agent: $agentStatus'),
            _FactPill(icon: Icons.check_circle_outline, label: 'Order: $orderStatus'),
            _FactPill(icon: Icons.local_shipping_outlined, label: 'Mode: $mode'),
            _FactPill(icon: Icons.timer_outlined, label: 'ETA: $eta'),
          ],
        ),
      ],
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final items = order.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Items"),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text("No items", style: TextStyle(color: Colors.black54))
        else
          Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (item.image != null && item.image!.trim().isNotEmpty)
                          ? Image.network(item.image!, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported_outlined))
                          : const Icon(Icons.image_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name ?? 'Item',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Qty: ${item.quantity ?? 0}',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('₹${item.price ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final a = order.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Delivery Address"),
        const SizedBox(height: 12),
        if (a == null)
          const Text("No address provided.", style: TextStyle(color: Colors.black54))
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${a.street ?? 'N/A'}\n${a.city ?? 'N/A'}, ${a.state ?? 'N/A'} ${a.zip ?? 'N/A'}",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              LocationButton(address: a),
            ],
          ),
      ],
    );
  }
}


class _StoreAddressSection extends StatelessWidget {
  const _StoreAddressSection({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final a = order.storeData?.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Store Address"),
        const SizedBox(height: 12),
        if (a == null)
          const Text("No address provided.", style: TextStyle(color: Colors.black54))
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${a.street ?? 'N/A'}\n${a.city ?? 'N/A'}, ${a.state ?? 'N/A'} ${a.zip ?? 'N/A'}",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(width: 6)
            ],
          ),
      ],
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.order,
    required this.isPaymentLoading,
    required this.onUpdatePayment,
  });

  final OrderModel order;
  final bool isPaymentLoading;
  final VoidCallback onUpdatePayment;

  @override
  Widget build(BuildContext context) {
    final method = order.paymentMethod ?? 'N/A';
    final status = order.paymentStatus ?? 'N/A';
    final total = '₹${order.total ?? 0}';

    final canUpdate =
        method == "Cash on Delivery" && status == "Pending" && order.deliveryAgentStatus == "Delivering";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Payment Details"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FactPill(icon: Icons.account_balance_wallet_outlined, label: 'Method: $method'),
            _FactPill(icon: Icons.receipt_long_outlined, label: 'Status: $status'),
            _FactPill(icon: Icons.payments_outlined, label: 'Total: $total'),
          ],
        ),
        if (canUpdate) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPaymentLoading ? null : onUpdatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isPaymentLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Update Payment Status"),
            ),
          ),
        ],
      ],
    );
  }
}