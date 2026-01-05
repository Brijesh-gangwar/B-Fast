
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/data/colors.dart';

import 'package:b_fast_user_app/models/product_model.dart';
import 'package:b_fast_user_app/providers/cart_provider.dart';
import 'package:b_fast_user_app/providers/wishlist_provider.dart';
import 'package:b_fast_user_app/screens/cart_screen.dart';
import 'package:b_fast_user_app/screens/wishlist_screen.dart';
import 'package:b_fast_user_app/widgets/wishlist/wishlist_button_widget.dart';

import '../snackbar_fxn.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _currentPrice = 0;
  double _originalPrice = 0;
  int _discountPercent = 0;

  bool _isWishlistLoading = false;

  final PageController _pageController = PageController();
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    if ((widget.product.price?.isNotEmpty ?? false)) {
      _updatePrice(_selectedSizeIndex);
    }
  }

  void _updatePrice(int sizeIndex) {
    final prices = widget.product.price;
    if (prices != null && sizeIndex >= 0 && sizeIndex < prices.length) {
      final current = prices[sizeIndex];
      setState(() {
        _selectedSizeIndex = sizeIndex;
        _currentPrice = current;
        _originalPrice = _currentPrice / 0.85;
        _discountPercent =
            ((_originalPrice - _currentPrice) / _originalPrice * 100).round();
      });
    }
  }

  Future<void> _toggleWishlistBottomBar() async {
    setState(() => _isWishlistLoading = true);
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);

    try {
      final pid = widget.product.productId;
      if (pid == null || pid.isEmpty) {
        showCustomMessage(context, "Missing product id");
      } else {
        await wishlistProvider.toggleProduct(pid);
        if (!mounted) return;
        final wished = wishlistProvider.isWishlisted(pid);
        showCustomMessage(
            context, wished ? "Added to wishlist ❤️" : "Removed from wishlist ❌");
      }
    } catch (e) {
      showCustomMessage(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isWishlistLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final isAdding = cartProvider.isUpdating(widget.product.productId ?? "");
    final isWished =
        wishlistProvider.isWishlisted(widget.product.productId ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        title: Text(
          widget.product.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              // TODO: implement share
            },
            icon: const Icon(Icons.share_outlined, color: Colors.black),
          ),
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
            icon: const Icon(Icons.favorite_border, color: Colors.black),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // No SafeArea needed here because AppBar handles top inset
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildImageCarouselBelowAppBar(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _DetailsBlock(
                      brand: widget.product.store.storeName ?? "Brand",
                      name: widget.product.name ?? 'Self Design Peplum Top',
                      ratingChip: _buildRatingChip(),
                      priceRow: _buildPriceInfo(),
                      colorSelector: (widget.product.color != null &&
                              widget.product.color!.isNotEmpty)
                          ? _buildColorSelector()
                          : const SizedBox.shrink(),
                      sizeSelector: (widget.product.size != null &&
                              widget.product.size!.isNotEmpty)
                          ? _buildSizeSelector()
                          : const SizedBox.shrink(),
                      uspRow: _uspRow(),
                      description: _buildExpansionTile(
                        'Product Description',
                        widget.product.description ??
                            'No description available.',
                      ),
                      delivery: _buildExpansionTile(
                        'Delivery & Services',
                        'Get your doorstep delivery within 90 mins. Hassle-free 7 days return & exchange available.',
                      ),
                      reviews: _reviews(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StickyBottomBar(
            productId: widget.product.productId!,
            isAdding: isAdding,
            isWished: isWished,
            isWishlistLoading: _isWishlistLoading,
            onToggleWishlist: _toggleWishlistBottomBar,
            onAddToBag: () async {
              try {
                await cartProvider.addItemToCart(
                  widget.product.productId ?? "",
                  1,
                  _selectedSizeIndex,
                  _selectedColorIndex,
                );
                showCustomMessage(context, "Added to Bag ✅");
              } catch (e) {
                showCustomMessage(context, "Error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  // Carousel placed under the AppBar so it doesn't reach the very top.
  Widget _buildImageCarouselBelowAppBar(BuildContext context) {
    final images = widget.product.images
            ?.map((e) => e.url ?? '')
            .where((u) => u.isNotEmpty)
            .toList() ??
        [];
    final height = MediaQuery.of(context).size.height * 0.5;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.isNotEmpty ? images.length : 1,
            onPageChanged: (i) => setState(() => _activePage = i),
            itemBuilder: (context, index) {
              final url = images.isNotEmpty ? images[index] : '';
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, _, __) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _activePage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("4.3",
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.star, color: Colors.white, size: 14),
            ],
          ),
        ),
        const SizedBox(width: 4),
        const Text("25 Ratings",
            style: TextStyle(color: Colors.black, fontSize: 12)),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('₹ $_currentPrice',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text('₹ ${_originalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 16)),
        const SizedBox(width: 8),
        Text('($_discountPercent% OFF)',
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colorName = widget.product.color ?? 'Unknown';
    final colorValue = colorSelectionicon().getColorFromName(colorName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorValue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              colorName[0].toUpperCase() + colorName.substring(1),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final sizes = widget.product.size ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('Select Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Size Chart >', style: TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(sizes.length, (index) {
            final size = sizes[index];
            final isSelected = _selectedSizeIndex == index;
            return GestureDetector(
              onTap: () => _updatePrice(index),
              child: Container(
                width: 70,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _uspRow() {
    final items = [
      (Icons.local_shipping_outlined, 'Fast Delivery'),
      (Icons.cached_outlined, '7-day Return'),
      (Icons.verified_outlined, 'Quality Checked'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (e) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200], shape: BoxShape.circle),
                  child: Icon(e.$1, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
      children: [
        Text(content, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _reviews() {
    final items = [
      ('Aman', 5.0, 'Great quality and fit!'),
      ('Neha', 4.0, 'Fabric feels nice, true to size.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
            title: 'Ratings & Reviews', subtitle: 'What people say'),
        const SizedBox(height: 8),
        ...items.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(r.$1,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(r.$2.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 2),
                            const Icon(Icons.star, size: 12, color: Colors.white),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.$3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsBlock extends StatelessWidget {
  final String brand;
  final String name;
  final Widget ratingChip;
  final Widget priceRow;
  final Widget colorSelector;
  final Widget sizeSelector;
  final Widget uspRow;
  final Widget description;
  final Widget delivery;
  final Widget reviews;

  const _DetailsBlock({
    required this.brand,
    required this.name,
    required this.ratingChip,
    required this.priceRow,
    required this.colorSelector,
    required this.sizeSelector,
    required this.uspRow,
    required this.description,
    required this.delivery,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(brand, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        ratingChip,
        const SizedBox(height: 12),
        priceRow,
        const SizedBox(height: 20),
        colorSelector,
        const SizedBox(height: 20),
        sizeSelector,
        const SizedBox(height: 20),
        uspRow,
        const SizedBox(height: 20),
        const Divider(),
        description,
        const Divider(),
        delivery,
        const Divider(),
        reviews,
        const SizedBox(height: 100),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(10),
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, color: Colors.black),
      onPressed: onPressed,
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final bool isAdding;
  final bool isWished;
  final bool isWishlistLoading;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToBag;

  final String productId;

  const _StickyBottomBar({
    required this.isAdding,
    required this.isWished,
    required this.isWishlistLoading,
    required this.onToggleWishlist,
    required this.onAddToBag,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          // 15% width: compact wishlist heart that turns black when wished
          Expanded(
            flex: 15,
            child: InkWell(
              onTap: isWishlistLoading ? null : onToggleWishlist,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isWishlistLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        color: Colors.black,
                        size: 24,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 85% width: larger Add to Bag button
          Expanded(
            flex: 85,
            child: ElevatedButton.icon(
              onPressed: isAdding ? null : onAddToBag,
              icon: isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              label: Text(isAdding ? '' : 'Add to Bag'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ]),
      TextButton(onPressed: () {}, child: const Text('View all >')),
    ]);
  }
}
