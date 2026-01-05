
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:b_fast_user_app/services/order_service.dart';
import 'package:b_fast_user_app/services/auth_service.dart';
import 'package:b_fast_user_app/providers/cart_provider.dart';
import 'package:b_fast_user_app/providers/user_provider.dart';

import '../../screens/main_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final dynamic address;
  final double totalPrice;
  final String? storeId;

  const PaymentSelectionScreen({
    super.key,
    required this.address,
    required this.totalPrice,
    this.storeId,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? _selectedMethod;
  bool _isPlacingOrder = false;

  final OrderService _orderService = OrderService();
  final AuthService authService = AuthService();

  CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();

  static const clientId = 'TEST106725695c949e5b51106a0f061796527601';
  static const clientSecret =
      'cfsk_ma_test_de7445b385ba6c73b2a8e3f384aa8abc_a757ce74';

  @override
  void initState() {
    super.initState();
  }

  Future<String> _generateOrderId() async {
    final userId = await authService.getUserId();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$userId-$timestamp";
  }

  Future<CFSession?> _createPaymentSession(String orderId) async {
    final user = Provider.of<UserProvider>(context, listen: false).userDetails;

    final url = Uri.parse('https://sandbox.cashfree.com/pg/orders');
    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-api-version': '2023-08-01',
      'x-client-id': clientId,
      'x-client-secret': clientSecret,
    };

    final body = jsonEncode({
      "order_amount": widget.totalPrice,
      "order_currency": "INR",
      "customer_details": {
        "customer_id": user?.userId ?? orderId,
        "customer_name": user?.name ?? "Guest User",
        "customer_email": user?.email ?? "guest@example.com",
        "customer_phone": user?.phone ?? "9999999999"
      },
      "order_meta": {"return_url": "https://www.cashfree.com/devstudio/thankyou"},
      "order_id": orderId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CFSessionBuilder()
            .setEnvironment(CFEnvironment.SANDBOX)
            .setOrderId(orderId)
            .setPaymentSessionId(data['payment_session_id'])
            .build();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create payment session: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
    return null;
  }

  Future<Map<String, String>?> _makeOnlinePayment(String orderId) async {
    Map<String, String>? result;

    cfPaymentGatewayService.setCallback((orderIdFromSdk) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final paymentId = "$orderId-DROP-$timestamp";
      result = {
        "paymentId": paymentId,
        "paymentMethod": "DROP_CHECKOUT",
        "paymentStatus": "SUCCESS"
      };
    }, (errorResponse, orderIdFromSdk) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final paymentId = "$orderId-DROP-$timestamp";
      result = {
        "paymentId": paymentId,
        "paymentMethod": "DROP_CHECKOUT",
        "paymentStatus": "FAILED",
        "error": errorResponse.toString()
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${errorResponse.toString()}")),
      );
    });

    final session = await _createPaymentSession(orderId);
    if (session != null) {
      await cfPaymentGatewayService.doPayment(
        CFDropCheckoutPaymentBuilder().setSession(session).build(),
      );

      while (result == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return result;
    }
    return null;
  }

  Future<void> _placeOrder() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a payment method")),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final orderId = await _generateOrderId();
      String? paymentId;
      String paymentStatus;
      String paymentMethod = _selectedMethod!;
      String storeid = widget.storeId!;

      if (_selectedMethod == "Cash on Delivery") {
        paymentId = null;
        paymentStatus = "Pending";
      } else {
        final paymentResult = await _makeOnlinePayment(orderId);
        if (paymentResult == null) {
          setState(() => _isPlacingOrder = false);
          return;
        }
        paymentId = paymentResult['paymentId'];
        paymentStatus = paymentResult['paymentStatus']!;
        paymentMethod = paymentResult['paymentMethod']!;
        if (paymentStatus != "SUCCESS" && paymentStatus != "PENDING") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment not completed: $paymentStatus")),
          );
          setState(() => _isPlacingOrder = false);
          return;
        }
      }

      final success = await _orderService.createOrder(
        widget.address.addressId!,
        paymentMethod,
        paymentStatus,
        paymentId ?? "null",
        orderId,
        storeid,
      );

      if (success && mounted) {
        Provider.of<CartProvider>(context, listen: false).cartItems.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userDetails;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Colors.black,
        ),
        title: const Text("Confirm Order"),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(
                      context: context,
                      icon: Icons.location_on_outlined,
                      title: "Delivery Address",
                      child: Text(
                        "${user?.name ?? 'N/A'}\n"
                            "${widget.address.street}, ${widget.address.city}\n"
                            "${widget.address.state}, ${widget.address.zip}\n\n"
                            "Phone: ${user?.phone ?? 'N/A'}",
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.receipt_long_outlined,
                      title: "Order Summary",
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Total Amount", style: theme.textTheme.bodyMedium),
                        trailing: Text(
                          "₹${widget.totalPrice.toStringAsFixed(2)}",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodCard(context),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: _buildBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.payment_outlined, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Select Payment Method",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 10, indent: 16, endIndent: 16),
          // Options
          RadioListTile<String>(
            title: const Text("Cash on Delivery"),
            secondary: const Icon(Icons.delivery_dining_outlined),
            value: "Cash on Delivery",
            groupValue: _selectedMethod,
            onChanged: (val) => setState(() => _selectedMethod = val),
            activeColor: theme.primaryColor,
          ),
          RadioListTile<String>(
            title: const Text("Online Payment"),
            secondary: const Icon(Icons.credit_card_outlined),
            value: "Online",
            groupValue: _selectedMethod,
            onChanged: (val) => setState(() => _selectedMethod = val),
            activeColor: theme.primaryColor,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _isPlacingOrder
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _placeOrder,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text(
            "Place Order",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
