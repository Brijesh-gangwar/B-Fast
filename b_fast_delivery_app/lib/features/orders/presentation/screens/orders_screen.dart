
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // import '../../../../core/helpers/snackbar_fxn.dart';
// // import '../../data/models/order_model.dart';
// // import '../../../profile/presentation/view_model/agent_details_provider.dart';
// // import '../view_model.dart/order_provider.dart';

// // import '../widgets/order_card.dart';

// // class OrderScreen extends StatefulWidget {
// //   const OrderScreen({super.key});

// //   @override
// //   State<OrderScreen> createState() => _OrderScreenState();
// // }

// // class _OrderScreenState extends State<OrderScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   String? _employeeId;
// //   bool _ordersFetched = false;

// //   // Add Delivered as third tab
// //   final List<String> statuses = ["Assigned", "Delivering", "Delivered"];
// //   final Map<String, ScrollController> _scrollControllers = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: statuses.length, vsync: this);

// //     // Add controllers for all three tabs
// //     for (var status in statuses) {
// //       _scrollControllers[status] = ScrollController();
// //       _scrollControllers[status]!.addListener(() => _handleScroll(status));
// //     }

// //     // Optionally trigger fetch when switching to Delivered tab
// //     _tabController.addListener(() {
// //       if (!_tabController.indexIsChanging &&
// //           statuses[_tabController.index] == "Delivered" &&
// //           _employeeId != null) {
// //         final provider = context.read<OrderProvider>();
// //         if (provider.deliveredOrders().isEmpty &&
// //             !provider.isLoading("Delivered")) {
// //           provider.fetchOrders(deliveryAgentStatus: "Delivered");
// //         }
// //       }
// //     });
// //   }

// //   void _fetchInitialOrders() {
// //     if (_employeeId != null && !_ordersFetched) {
// //       for (var status in statuses) {
// //         _fetchOrdersForStatus(status);
// //       }
// //       setState(() {
// //         _ordersFetched = true;
// //       });
// //     }
// //   }

// //   void _fetchOrdersForStatus(String status) {
// //     if (_employeeId == null) return;
// //     final provider = context.read<OrderProvider>();
// //     List<OrderModel> currentOrders;
// //     switch (status) {
// //       case "Assigned":
// //         currentOrders = provider.assignedOrders();
// //         break;
// //       case "Delivering":
// //         currentOrders = provider.deliveringOrders();
// //         break;
// //       case "Delivered":
// //         currentOrders = provider.deliveredOrders();
// //         break;
// //       default:
// //         return;
// //     }
// //     if (currentOrders.isEmpty) {
// //       provider.fetchOrders(deliveryAgentStatus: status);
// //     }
// //   }

// //   void _handleScroll(String status) {
// //     if (_employeeId == null) return;
// //     final provider = context.read<OrderProvider>();
// //     final controller = _scrollControllers[status];
// //     if (controller != null &&
// //         controller.position.pixels >=
// //             controller.position.maxScrollExtent - 200 &&
// //         !provider.isLoading(status) &&
// //         provider.hasMore(status)) {
// //       provider.fetchOrders(deliveryAgentStatus: status);
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     _scrollControllers.forEach((_, controller) => controller.dispose());
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<AgentDetailsProvider>(
// //       builder: (context, agentProvider, child) {
// //         if (agentProvider.agentDetails != null && !_ordersFetched) {
// //           _employeeId = agentProvider.agentDetails!.employeeId;
// //           Future.microtask(() => _fetchInitialOrders());
// //         }
// //         return Scaffold(
// //           backgroundColor: Colors.white,
// //           appBar: AppBar(
// //             backgroundColor: Colors.white,
// //             foregroundColor: Colors.black,
// //             elevation: 0,
// //             title: const Text(
// //               "Orders",
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               style: TextStyle(fontWeight: FontWeight.w700),
// //             ),

// //             bottom: TabBar(
// //               controller: _tabController,
// //               labelColor: Colors.black,
// //               unselectedLabelColor: Colors.black54,
// //               indicatorColor: Colors.black,
// //               tabs: statuses
// //                   .map((s) => Tab(
// //                 child: Text(
// //                   s,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ))
// //                   .toList(),
// //             ),
// //           ),
// //           body: _employeeId == null
// //               ? const Center(child: CircularProgressIndicator())
// //               : TabBarView(
// //             controller: _tabController,
// //             children: statuses.map((status) => _buildTab(status)).toList(),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildTab(String status) {
// //     return Consumer<OrderProvider>(
// //       builder: (context, provider, child) {
// //         List<OrderModel> orders;
// //         switch (status) {
// //           case "Assigned":
// //             orders = provider.assignedOrders();
// //             break;
// //           case "Delivering":
// //             orders = provider.deliveringOrders();
// //             break;
// //           case "Delivered":
// //             orders = provider.deliveredOrders();
// //             break;
// //           default:
// //             orders = [];
// //         }

// //         if (orders.isEmpty && provider.isLoading(status)) {
// //           return const Center(child: CircularProgressIndicator());
// //         }
// //         if (orders.isEmpty) {
// //           return Center(
// //             child: Text(
// //               status == "Delivered"
// //                   ? "No Delivered Orders Found"
// //                   : "No Orders Found",
// //             ),
// //           );
// //         }

// //         return RefreshIndicator(
// //           onRefresh: () async {
// //             provider.reset(deliveryAgentStatus: status);
// //             await provider.fetchOrders(deliveryAgentStatus: status);
// //           },
// //           child: ListView.builder(
// //             controller: _scrollControllers[status],
// //             padding: EdgeInsets.zero,
// //             itemCount: orders.length + (provider.hasMore(status) ? 1 : 0),
// //             itemBuilder: (context, index) {
// //               if (index == orders.length) {
// //                 return const Padding(
// //                   padding: EdgeInsets.all(16.0),
// //                   child: Center(child: CircularProgressIndicator()),
// //                 );
// //               }
// //               return OrderCard(order: orders[index]);
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // Kept for completeness; now the history icon switches tabs rather than pushing.
// //   void _showDeliveredOrders() {
// //     if (_employeeId == null) {
// //       showCustomMessage(
// //         context,
// //         "Cannot show history. Please wait for user details to load.",
// //       );
// //       return;
// //     }
// //     // Switch to Delivered tab instead of navigation (kept consistent with UI request)
// //     _tabController.index = 2;
// //     final provider = context.read<OrderProvider>();
// //     if (provider.deliveredOrders().isEmpty &&
// //         !provider.isLoading("Delivered")) {
// //       provider.fetchOrders(deliveryAgentStatus: "Delivered");
// //     }
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../../core/helpers/snackbar_fxn.dart';
// import '../../data/models/order_model.dart';
// import '../../../profile/presentation/view_model/agent_details_provider.dart';
// import '../view_model.dart/order_provider.dart';

// import '../widgets/order_card.dart';

// class OrderScreen extends StatefulWidget {
//   const OrderScreen({super.key});

//   @override
//   State<OrderScreen> createState() => _OrderScreenState();
// }

// class _OrderScreenState extends State<OrderScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String? _employeeId;
//   bool _ordersFetched = false;

//   /// Tabs for different delivery statuses
//   final List<String> statuses = ["Assigned", "Delivering", "Delivered"];
//   final Map<String, ScrollController> _scrollControllers = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: statuses.length, vsync: this);

//     // Initialize scroll controllers for each tab
//     for (var status in statuses) {
//       _scrollControllers[status] = ScrollController();
//       _scrollControllers[status]!.addListener(() => _handleScroll(status));
//     }

//     // Lazy load delivered orders when tab is opened
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging &&
//           statuses[_tabController.index] == "Delivered" &&
//           _employeeId != null) {
//         final provider = context.read<OrderProvider>();
//         if (provider.deliveredOrders().isEmpty &&
//             !provider.isLoading("Delivered")) {
//           provider.fetchOrders(deliveryAgentStatus: "Delivered");
//         }
//       }
//     });
//   }

//   /// Fetch initial orders for all statuses once agent details are available
//   void _fetchInitialOrders() {
//     if (_employeeId != null && !_ordersFetched) {
//       for (var status in statuses) {
//         _fetchOrdersForStatus(status);
//       }
//       setState(() {
//         _ordersFetched = true;
//       });
//     }
//   }

//   void _fetchOrdersForStatus(String status) {
//     if (_employeeId == null) return;
//     final provider = context.read<OrderProvider>();
//     List<OrderModel> currentOrders;

//     switch (status) {
//       case "Assigned":
//         currentOrders = provider.assignedOrders();
//         break;
//       case "Delivering":
//         currentOrders = provider.deliveringOrders();
//         break;
//       case "Delivered":
//         currentOrders = provider.deliveredOrders();
//         break;
//       default:
//         return;
//     }

//     if (currentOrders.isEmpty) {
//       provider.fetchOrders(deliveryAgentStatus: status);
//     }
//   }

//   /// Pagination scroll listener
//   void _handleScroll(String status) {
//     if (_employeeId == null) return;
//     final provider = context.read<OrderProvider>();
//     final controller = _scrollControllers[status];

//     if (controller != null &&
//         controller.position.pixels >=
//             controller.position.maxScrollExtent - 200 &&
//         !provider.isLoading(status) &&
//         provider.hasMore(status)) {
//       provider.fetchOrders(deliveryAgentStatus: status);
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _scrollControllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AgentDetailsProvider>(
//       builder: (context, agentProvider, child) {
//         // Fetch orders when employeeId becomes available
//         if (agentProvider.agentDetails != null && !_ordersFetched) {
//           _employeeId = agentProvider.agentDetails!.employeeId;
//           Future.microtask(() => _fetchInitialOrders());
//         }

//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//             title: const Text(
//               "Orders",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontWeight: FontWeight.w700),
//             ),
//             bottom: TabBar(
//               controller: _tabController,
//               labelColor: Colors.black,
//               unselectedLabelColor: Colors.black54,
//               indicatorColor: Colors.black,
//               tabs: statuses
//                   .map((status) => Tab(
//                         child: Text(
//                           status,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//           body: _employeeId == null
//               ? const Center(child: CircularProgressIndicator())
//               : TabBarView(
//                   controller: _tabController,
//                   children: statuses.map(_buildTab).toList(),
//                 ),
//         );
//       },
//     );
//   }

//   /// Build each tab (Assigned / Delivering / Delivered)
//   Widget _buildTab(String status) {
//     return Consumer<OrderProvider>(
//       builder: (context, provider, child) {
//         List<OrderModel> orders;

//         switch (status) {
//           case "Assigned":
//             orders = provider.assignedOrders();
//             break;
//           case "Delivering":
//             orders = provider.deliveringOrders();
//             break;
//           case "Delivered":
//             orders = provider.deliveredOrders();
//             break;
//           default:
//             orders = [];
//         }

//         final isLoading = provider.isLoading(status);
//         final hasMore = provider.hasMore(status);

//         if (orders.isEmpty && isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (orders.isEmpty) {
//           return Center(
//             child: Text(
//               status == "Delivered"
//                   ? "No Delivered Orders Found"
//                   : "No Orders Found",
//               style: const TextStyle(color: Colors.black54),
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () async {
//             provider.reset(deliveryAgentStatus: status);
//             await provider.fetchOrders(deliveryAgentStatus: status);
//           },
//           child: ListView.builder(
//             controller: _scrollControllers[status],
//             padding: EdgeInsets.zero,
//             itemCount: orders.length + (hasMore ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index == orders.length) {
//                 return const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }
//               return OrderCard(order: orders[index]);
//             },
//           ),
//         );
//       },
//     );
//   }

//   /// If needed — manually switch to Delivered tab
//   void _showDeliveredOrders() {
//     if (_employeeId == null) {
//       showCustomMessage(
//         context,
//         "Cannot show history. Please wait for user details to load.",
//       );
//       return;
//     }

//     _tabController.index = 2; // Switch to Delivered tab
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/helpers/snackbar_fxn.dart';
import '../../data/models/order_model.dart';
import '../../../profile/presentation/view_model/agent_details_provider.dart';
import '../view_model.dart/order_provider.dart';
import '../widgets/order_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _employeeId;
  bool _ordersFetched = false;

  final List<String> statuses = ["Assigned", "Delivering", "Delivered"];
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);

    for (var status in statuses) {
      _scrollControllers[status] = ScrollController();
      _scrollControllers[status]!.addListener(() => _handleScroll(status));
    }

    // Lazy load "Delivered" tab when opened
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          statuses[_tabController.index] == "Delivered" &&
          _employeeId != null) {
        final provider = context.read<OrderProvider>();
        if (provider.deliveredOrders().isEmpty &&
            !provider.isLoading("Delivered")) {
          provider.fetchOrders(deliveryAgentStatus: "Delivered");
        }
      }
    });
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopAssignedAutoRefresh();
    _tabController.dispose();
    _scrollControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  /// Pagination logic for infinite scroll
  void _handleScroll(String status) {
    final provider = context.read<OrderProvider>();
    final controller = _scrollControllers[status];
    if (controller == null) return;

    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 200 &&
        !provider.isLoading(status) &&
        provider.hasMore(status)) {
      provider.fetchOrders(deliveryAgentStatus: status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AgentDetailsProvider, OrderProvider>(
      builder: (context, agentProvider, orderProvider, _) {
        // Initialize once when agent details are ready
        if (agentProvider.agentDetails != null && !_ordersFetched) {
          _employeeId = agentProvider.agentDetails!.employeeId;
          _ordersFetched = true;

          // Fetch all statuses once
          for (var status in statuses) {
            orderProvider.fetchOrders(deliveryAgentStatus: status);
          }

          // Start auto-refresh for Assigned
          orderProvider.startAssignedAutoRefresh();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              "Orders",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black,
              tabs: statuses.map((status) => Tab(text: status)).toList(),
            ),
          ),
          // body: _employeeId == null
          //     ? const Center(child: CircularProgressIndicator())
          //     : TabBarView(
          //         controller: _tabController,
          //         children: statuses.map((status) {
          //           return _buildOrderTab(context, orderProvider, status);
          //         }).toList(),
          //       ),
          body: _employeeId == null
    ? const Center(child: CircularProgressIndicator())
    : Padding(
        padding: const EdgeInsets.only(bottom: 80), // 👈 adjust as needed
        child: TabBarView(
          controller: _tabController,
          children: statuses.map((status) {
            return _buildOrderTab(context, orderProvider, status);
          }).toList(),
        ),
      ),

        );
      },
    );
  }

  /// Builds each tab list dynamically from provider
  Widget _buildOrderTab(
      BuildContext context, OrderProvider provider, String status) {
    List<OrderModel> orders;
    switch (status) {
      case "Assigned":
        orders = provider.assignedOrders();
        break;
      case "Delivering":
        orders = provider.deliveringOrders();
        break;
      case "Delivered":
        orders = provider.deliveredOrders();
        break;
      default:
        orders = [];
    }

    final isLoading = provider.isLoading(status);
    final hasMore = provider.hasMore(status);

    if (orders.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Text(
          "No $status Orders Found",
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.reset(deliveryAgentStatus: status);
        await provider.fetchOrders(deliveryAgentStatus: status);
      },
      child: ListView.builder(
        controller: _scrollControllers[status],
        padding: EdgeInsets.zero,
        itemCount: orders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }

  /// Helper to show delivered orders manually if needed
  void _showDeliveredOrders() {
    if (_employeeId == null) {
      showCustomMessage(
        context,
        "Cannot show history. Please wait for user details to load.",
      );
      return;
    }
    _tabController.index = 2; // Switch to Delivered tab
  }
}
