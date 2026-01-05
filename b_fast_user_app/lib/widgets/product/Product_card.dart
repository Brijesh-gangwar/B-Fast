

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/product_model.dart';
import 'package:b_fast_user_app/providers/wishlist_provider.dart';


import 'product_details_widget.dart';
import '../wishlist/wishlist_button_widget.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Use the first price in the list as the display price.
    final displayPrice = (product.price != null && product.price!.isNotEmpty)
        ? product.price!.first
        : 0;

    return GestureDetector(
      onTap: () {
        // Navigate to the ProductDetailScreen on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        clipBehavior: Clip.antiAlias, // Ensures the image respects the card's border radius
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section with Wishlist Icon
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product_image_${product.productId}', // For smooth transition animation
                      child: CachedNetworkImage(
                        imageUrl: product.images?.first.url ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, child) {
                         wishlist.isWishlisted(product.productId ?? '');
                        return SizedBox(
                        height: 28,
                        width: 28,
                        child: WishlistButton(productId: product.productId!),
                      );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Product Details Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$displayPrice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}