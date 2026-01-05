


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/providers/wishlist_provider.dart';

import '../snackbar_fxn.dart';

class WishlistButton extends StatefulWidget {
  final String productId;
  const WishlistButton({super.key, required this.productId});

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool _isLoading = false;

  Future<void> _toggleWishlist(BuildContext context) async {
    setState(() => _isLoading = true);

    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);

    try {
      await wishlistProvider.toggleProduct(widget.productId);


              showCustomMessage(context,wishlistProvider.isWishlisted(widget.productId)
                ? "Added to wishlist ❤️"
                : "Removed from wishlist ❌");
    } catch (e) {

      showAboutDialog(context: context, children: [Text("Error: $e")]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isWishlisted = wishlistProvider.isWishlisted(widget.productId);

        return IconButton(
          onPressed: _isLoading ? null : () => _toggleWishlist(context),
          icon: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.grey,
                ),
        );
      },
    );
  }
}
