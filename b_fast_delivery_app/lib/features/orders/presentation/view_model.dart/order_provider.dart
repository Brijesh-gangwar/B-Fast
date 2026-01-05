




import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  final Map<String, List<OrderModel>> _ordersByStatus = {
    "Assigned": [],
    "Delivering": [],
    "Delivered": [],
  };

  final Map<String, String?> _cursorByStatus = {
    "Assigned": null,
    "Delivering": null,
    "Delivered": null,
  };

  final Map<String, bool> _hasMoreByStatus = {
    "Assigned": true,
    "Delivering": true,
    "Delivered": true,
  };

  final Map<String, bool> _isLoadingByStatus = {
    "Assigned": false,
    "Delivering": false,
    "Delivered": false,
  };

  Timer? _assignedRefreshTimer;

  // 🧩 Getters
  List<OrderModel> assignedOrders() => _ordersByStatus["Assigned"]!;
  List<OrderModel> deliveringOrders() => _ordersByStatus["Delivering"]!;
  List<OrderModel> deliveredOrders() => _ordersByStatus["Delivered"]!;
  bool isLoading(String status) => _isLoadingByStatus[status] ?? false;
  bool hasMore(String status) => _hasMoreByStatus[status] ?? true;

  /// 🔄 Fetch orders with pagination + optional refresh flag
  Future<void> fetchOrders({
    required String deliveryAgentStatus,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (!_isLoadingByStatus.containsKey(deliveryAgentStatus)) return;
    if (isLoading(deliveryAgentStatus)) return;
    if (!hasMore(deliveryAgentStatus) && !refresh) return;

    _isLoadingByStatus[deliveryAgentStatus] = true;
    notifyListeners();

    try {
      if (refresh) {
        reset(deliveryAgentStatus: deliveryAgentStatus);
      }

      final data = await _orderService.fetchOrders(
        deliveryAgentStatus: deliveryAgentStatus,
        cursor: _cursorByStatus[deliveryAgentStatus],
        limit: limit,
      );

      final List<OrderModel> newOrders = data["orders"];
      final String? nextCursor = data["nextCursor"];

      if (refresh) {
        _ordersByStatus[deliveryAgentStatus] = newOrders;
      } else {
        _appendUniqueOrders(deliveryAgentStatus, newOrders);
      }

      _cursorByStatus[deliveryAgentStatus] = nextCursor;
      _hasMoreByStatus[deliveryAgentStatus] = nextCursor != null;
    } catch (e) {
      debugPrint("❌ Error fetching orders for $deliveryAgentStatus: $e");
    } finally {
      _isLoadingByStatus[deliveryAgentStatus] = false;
      notifyListeners();
    }
  }

  /// ✅ Helper to append only non-duplicate new orders
  void _appendUniqueOrders(String status, List<OrderModel> newOrders) {
    final existingIds =
        _ordersByStatus[status]!.map((order) => order.sId).toSet();

    final uniqueOrders =
        newOrders.where((order) => !existingIds.contains(order.sId)).toList();

    if (uniqueOrders.isNotEmpty) {
      _ordersByStatus[status]!.addAll(uniqueOrders);
      notifyListeners();
    }
  }

  /// 🚚 Update delivery agent status
  Future<bool> updateDeliveryAgentStatus({
    required String orderId,
    required String currentStatus,
    required String newStatus,
  }) async {
    final success = await _orderService.updateAgentOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
    );

    if (success) {
      final index = _ordersByStatus[currentStatus]
          ?.indexWhere((order) => order.sId == orderId);
      if (index != null && index != -1) {
        final orderToMove = _ordersByStatus[currentStatus]!.removeAt(index);
        orderToMove.deliveryAgentStatus = newStatus;

        if (_ordersByStatus.containsKey(newStatus)) {
          _ordersByStatus[newStatus]!.insert(0, orderToMove);
        }

        if (newStatus == "Delivered") {
          reset(deliveryAgentStatus: "Delivered");
          fetchOrders(deliveryAgentStatus: "Delivered");
        } else {
          notifyListeners();
        }
      }
    }
    return success;
  }

  /// 💰 Update payment status
  Future<bool> updatePaymentStatus({
    required String orderId,
    required String newPaymentStatus,
  }) async {
    final success = await _orderService.updatePaymentStatus(
      orderId: orderId,
      paymentStatus: newPaymentStatus,
    );

    if (success) {
      _updateLocalOrder(orderId, (order) {
        order.paymentStatus = newPaymentStatus;
      });
      notifyListeners();
    }
    return success;
  }

  /// 📦 Update main order status
  Future<bool> updateMainOrderStatus({
    required String orderId,
    required String newOrderStatus,
  }) async {
    final success = await _orderService.updateOrderStatus(
      orderId: orderId,
      newOrderStatus: newOrderStatus,
    );

    if (success) {
      _updateLocalOrder(orderId, (order) {
        order.orderStatus = newOrderStatus;
      });
      notifyListeners();
    }
    return success;
  }

  /// 🧠 Local order updater
  void _updateLocalOrder(String orderId, void Function(OrderModel) updateAction) {
    for (var list in _ordersByStatus.values) {
      final index = list.indexWhere((o) => o.sId == orderId);
      if (index != -1) {
        updateAction(list[index]);
        return;
      }
    }
  }

  /// 🧹 Reset order data for a specific status or all
  void reset({String? deliveryAgentStatus}) {
    if (deliveryAgentStatus != null &&
        _ordersByStatus.containsKey(deliveryAgentStatus)) {
      _ordersByStatus[deliveryAgentStatus]?.clear();
      _cursorByStatus[deliveryAgentStatus] = null;
      _hasMoreByStatus[deliveryAgentStatus] = true;
      _isLoadingByStatus[deliveryAgentStatus] = false;
    } else {
      _ordersByStatus.forEach((key, _) => _ordersByStatus[key] = []);
      _cursorByStatus.updateAll((_, __) => null);
      _hasMoreByStatus.updateAll((_, __) => true);
      _isLoadingByStatus.updateAll((_, __) => false);
    }
    notifyListeners();
  }

  /// 🔁 Auto-refresh "Assigned" every 4 seconds, only appending new items
  void startAssignedAutoRefresh() {
    stopAssignedAutoRefresh(); // avoid duplicates
    _assignedRefreshTimer =
        Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!_isLoadingByStatus["Assigned"]!) {
        try {
          final data = await _orderService.fetchOrders(
                       deliveryAgentStatus: "Assigned",
            limit: 10,
          );

          final List<OrderModel> newOrders = data["orders"];
          _appendUniqueOrders("Assigned", newOrders);
        } catch (e) {
          debugPrint("⚠️ Auto-refresh failed for Assigned: $e");
        }
      }
    });
  }

  /// ⏹️ Stop the periodic refresh
  void stopAssignedAutoRefresh() {
    _assignedRefreshTimer?.cancel();
    _assignedRefreshTimer = null;
  }

  @override
  void dispose() {
    stopAssignedAutoRefresh();
    super.dispose();
  }
}

