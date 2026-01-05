import 'dart:convert';
import 'package:b_fast_delivery_app/core/secrets.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../../../auth/data/services/auth_service.dart';

class OrderService {
  final AuthService authService = AuthService();
  final String baseurl = "$baseUrl/orders";


// fetch all orders assigned to delivery agent
  Future<Map<String, dynamic>> fetchOrders({
    required String deliveryAgentStatus,
    int limit = 10,
    String? cursor,
  }) async {
    final employeeId = await authService.getSavedEmployeeId();
    final Uri url = Uri.parse(
      "$baseurl?employeeId=$employeeId&deliveryAgentStatus=$deliveryAgentStatus&limit=$limit&cursor=${cursor ?? ''}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<OrderModel> orders =
          (data['data'] as List)
              .map((order) => OrderModel.fromJson(order))
              .toList();


  print('Fetched ${orders.length} orders for status $deliveryAgentStatus');

      return {"orders": orders, "nextCursor": data['nextCursor']};
    } else {
      throw Exception('Failed to load orders');
    }
  }



  // update agent status of order
  Future<bool> updateAgentOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/orders/update-delivery-status',
    );

    final employeeId = await authService.getSavedEmployeeId();
    if (employeeId == null) {
      return false; 
    }

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'orderId': orderId,
      'employeeId': employeeId,
      'deliveryAgentStatus': newStatus,
    });

    try {
      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }


// update payment status of order
  Future<bool> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {

    final employeeId = await authService.getSavedEmployeeId();

    final Uri url = Uri.parse(
      '$baseUrl/orders/update-payment-status',
    );

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'orderId': orderId,
      "employeeId": employeeId,
      "paymentStatus": paymentStatus,
    });

    try {
      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  // update order status 
  Future<bool> updateOrderStatus({
    required String orderId,
    required String newOrderStatus,
  }) async {

    final employeeId = await authService.getSavedEmployeeId();

    final Uri url = Uri.parse(
      '$baseUrl/orders/update-order-status',
    );

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'orderId': orderId,
      "employeeId": employeeId,
      "orderStatus": newOrderStatus,
    });

    try {
      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


}
