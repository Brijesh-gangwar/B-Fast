

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../view_model.dart/order_provider.dart';
// import '../widgets/order_card.dart';

// class DeliveredOrdersScreen extends StatefulWidget {
//   const DeliveredOrdersScreen({super.key});

//   @override
//   State<DeliveredOrdersScreen> createState() => _DeliveredOrdersScreenState();
// }

// class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       final provider = context.read<OrderProvider>();
//       if (provider.deliveredOrders().isEmpty) {
//         provider.fetchOrders(deliveryAgentStatus: "Delivered");
//       }
//     });
//     _scrollController.addListener(_handleScroll);
//   }

//   void _handleScroll() {
//     final provider = context.read<OrderProvider>();
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !provider.isLoading("Delivered") &&
//         provider.hasMore("Delivered")) {
//       provider.fetchOrders(deliveryAgentStatus: "Delivered");
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _onRefresh() async {
//     final provider = context.read<OrderProvider>();
//     provider.reset(deliveryAgentStatus: "Delivered");
//     await provider.fetchOrders(deliveryAgentStatus: "Delivered");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text("Delivered Orders", maxLines: 1, overflow: TextOverflow.ellipsis)),
//       body: Consumer<OrderProvider>(
//         builder: (context, provider, child) {
//           final orders = provider.deliveredOrders();
//           final isLoading = provider.isLoading("Delivered");
//           final hasMore = provider.hasMore("Delivered");

//           if (orders.isEmpty && isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (orders.isEmpty) {
//             return const Center(child: Text("No Delivered Orders Found"));
//           }

//           return RefreshIndicator(
//             onRefresh: _onRefresh,
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: EdgeInsets.zero,
//               itemCount: orders.length + (hasMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == orders.length) {
//                   return const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 final order = orders[index];
//                 return OrderCard(order: order);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }