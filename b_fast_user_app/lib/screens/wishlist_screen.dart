
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/wishlist_service.dart';
import '../models/wishlist_model.dart';
import '../widgets/snackbar_fxn.dart';
import '../widgets/wishlist/wish_product_details.dart';
// Kept in case used elsewhere

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistModel> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlistItems();
  }

  Future<void> fetchWishlistItems() async {
    setState(() => isLoading = true);
    try {
      final apiService = WishlistService();
      final List<WishlistModel> fetchedItems =
      await apiService.getAllWishlistItems();
      setState(() {
        wishlistItems = fetchedItems;
      });
    } catch (error) {
      if (mounted) {
        showCustomMessage(context, "Error fetching wishlist: $error");
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> removeFromWishlist(String wishlistId) async {
    try {
      final apiService = WishlistService();
      // ignore: avoid_print
      print("DEBUG: Removing wishlist item with id $wishlistId");
      final success = await apiService.removeFromWishlist(wishlistId);
      if (success) {
        setState(() {
          wishlistItems.removeWhere(
                (item) => item.product!.productId == wishlistId,
          );
        });
        showCustomMessage(context, "Removed from wishlist");
      }
    } catch (error) {
      showCustomMessage(context, "Error removing item: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Wishlist', style: textTheme.titleMedium),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistItems.isEmpty
          ? Center(
        child: Text(
          "No wishlist items found",
          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchWishlistItems,
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.6,
          ),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final item = wishlistItems[index];
            final product = item.product;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WishProductDetail(
                      product: product!,
                      productId: item.productId!,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image + bare close icon overlay (no white background)
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: _WishlistImage(
                              imageUrl: (product?.images?.isNotEmpty ?? false)
                                  ? (product!.images!.first.url ?? '')
                                  : null,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              splashRadius: 18,
                              iconSize: 18,
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  wishlistItems.removeAt(index);
                                });
                                showCustomMessage(
                                  context,
                                  "Removed from wishlist",
                                );
                                // If backend removal desired here too:
                                // removeFromWishlist(item.productId!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Product text
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _WishlistTexts(
                        titleStyle: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        subtitleStyle: textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                        productName: product?.name,
                        productDescription: product?.description,
                      ),
                    ),

                    // Move to Bag
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WishProductDetail(
                                product: product!,
                                productId: item.productId!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: Colors.black,
                        ),
                        label: Text(
                          'Move to Bag',
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WishlistImage extends StatelessWidget {
  final String? imageUrl;
  const _WishlistImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
      const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}

class _WishlistTexts extends StatelessWidget {
  final String? productName;
  final String? productDescription;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const _WishlistTexts({
    required this.productName,
    required this.productDescription,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final name =
    (productName?.trim().isNotEmpty ?? false) ? productName! : "No Name";
    final description =
    (productDescription?.trim().isNotEmpty ?? false) ? productDescription! : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        const SizedBox(height: 2),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

