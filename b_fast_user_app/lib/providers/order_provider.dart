
import 'package:flutter/material.dart';
import 'package:b_fast_user_app/models/order_model.dart';
import 'package:b_fast_user_app/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all orders for the current user
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getAllOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new order
  Future<bool> createOrder({
    required String addressId,
    required String paymentMethod,
    required String paymentStatus,
    required String paymentId,
    required String orderId,
    required String storeId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _orderService.createOrder(
        addressId,
        paymentMethod,
        paymentStatus,
        paymentId,
        orderId,
        storeId,
      );

      if (success) {
        await fetchOrders(); // Refresh order list after creation
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      if (success) await fetchOrders();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success =
          await _orderService.updateOrderPaymentStatus(orderId, paymentStatus);
      if (success) await fetchOrders();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optional: Clear orders
  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
}
