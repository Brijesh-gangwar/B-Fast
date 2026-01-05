
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/cart_model.dart';
import 'package:b_fast_user_app/providers/cart_provider.dart';
import 'package:b_fast_user_app/widgets/profile/address_selection_screen.dart';
import '../widgets/snackbar_fxn.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double convenienceFee = 20.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    double totalMRP = 0;
    if (cartItems.isNotEmpty) {
      totalMRP = cartItems.map((item) {
        final product = item.product!;
        final sizeIndex = item.optionIndex ?? 0;
        final currentPrice = product.price![sizeIndex].toDouble();
        final originalPrice = (currentPrice / 0.85);
        return originalPrice * (item.quantity ?? 1);
      }).reduce((a, b) => a + b);
    }
    final double discountOnMRP = totalMRP - cartProvider.totalPrice;
    final double totalAmount = cartProvider.totalPrice + convenienceFee;

    final String? storeId =
    cartItems.isNotEmpty ? cartItems.first.product?.storeId : null;

    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text('Shopping Bag'),
        // Removed the heart icon from actions
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text("Your shopping bag is empty."))
          : SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  if (item.product == null) return const SizedBox.shrink();
                  return _buildCartItem(context, item);
                },
                separatorBuilder: (context, index) =>
                const SizedBox(height: 16),
              ),
              const SizedBox(height: 24),
              _buildPriceDetails(
                totalMRP,
                discountOnMRP,
                convenienceFee,
                totalAmount,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? SafeArea(
        top: false,
        child: _buildPlaceOrderButton(context, totalAmount, storeId),
      )
          : null,
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStep('Bag', isActive: true),
        const Expanded(child: Divider()),
        _buildStep('Address'),
        const Expanded(child: Divider()),
        _buildStep('Payment'),
      ],
    );
  }

  Widget _buildStep(String title,
      {bool isActive = false, bool isComplete = false}) {
    final bool showCheck = isActive || isComplete;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive
              ? Colors.green
              : (isComplete ? Colors.green : Colors.grey.shade300),
          child: showCheck
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: showCheck ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartModel item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final product = item.product!;
    final sizeIndex = item.optionIndex ?? 0;
    final currentPrice = product.price![sizeIndex].toDouble();
    final originalPrice = (currentPrice / 0.85);
    final discountPercent =
    ((originalPrice - currentPrice) / originalPrice * 100).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.images?.first.url ?? 'https://via.placeholder.com/80x100',
            width: 80,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image,
              size: 80,
              color: Color.fromARGB(255, 120, 120, 120),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand/title + remove
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name ?? 'Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: cartProvider.isDeleting(item.sId!)
                        ? null
                        : () async => await cartProvider.removeItem(item.sId!),
                    child: cartProvider.isDeleting(item.sId!)
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.close, size: 18, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                (product.name ?? '').isNotEmpty
                    ? 'Sold by: ${product.name}'
                    : 'Sold by: —',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip('Size: ${product.size?[sizeIndex] ?? 'M'}'),
                  const SizedBox(width: 8),
                  _buildChip('Qty: ${item.quantity ?? 1}'),
                  const SizedBox(width: 8),
                  _buildQuantitySelector(cartProvider, item),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹ ${currentPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹ ${originalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($discountPercent% Off)',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildQuantitySelector(CartProvider cartProvider, CartModel item) {
    final isUpdating = cartProvider.isUpdating(item.productId!);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove, size: 18),
              onPressed: (item.quantity ?? 1) > 1 && !isUpdating
                  ? () {
                cartProvider.decreaseQuantityLocal(item.productId!);
                cartProvider.updateQuantity(item.productId!);
              }
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: isUpdating
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 18),
              onPressed: !isUpdating
                  ? () {
                cartProvider.increaseQuantityLocal(item.productId!);
                cartProvider.updateQuantity(item.productId!);
              }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildPriceDetails(
      double totalMRP,
      double discount,
      double fee,
      double total,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRICE DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPriceRow('Total MRP', '₹ ${totalMRP.toStringAsFixed(0)}'),
          _buildPriceRow('Discount on MRP', '- ₹ ${discount.toStringAsFixed(0)}', isDiscount: true),
          _buildPriceRow('Convenience Fee', '₹ ${fee.toStringAsFixed(0)}'),
          const Divider(),
          _buildPriceRow('Total Amount', '₹ ${total.toStringAsFixed(0)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context, double totalAmount, String? storeId) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total summary
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('₹ ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('View Details', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          // CTA with existing functional navigation and parameters preserved
          ElevatedButton(
            onPressed: () {
              if (storeId == null) {
                showCustomMessage(context, 'Could not find store information.');
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressSelectionScreen(
                    totalPrice: totalAmount,
                    storeId: storeId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}


