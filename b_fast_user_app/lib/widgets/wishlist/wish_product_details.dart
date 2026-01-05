
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/product_model.dart';
import 'package:b_fast_user_app/providers/cart_provider.dart';
import 'package:b_fast_user_app/providers/wishlist_provider.dart';
import 'package:b_fast_user_app/screens/cart_screen.dart';
import 'package:b_fast_user_app/screens/wishlist_screen.dart'; // <-- Added this import for the new UI
import 'package:b_fast_user_app/widgets/wishlist/wishlist_button_widget.dart';

import '../snackbar_fxn.dart';

class WishProductDetail extends StatefulWidget {
  final Product product;
  final String productId;

  const WishProductDetail(
      {super.key, required this.product, required this.productId});

  @override
  State<WishProductDetail> createState() => _WishProductDetailState();
}

class _WishProductDetailState extends State<WishProductDetail> {
  final int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _currentPrice = 0;
  double _originalPrice = 0;
  int _discountPercent = 0;
  // bool _isWishlistLoading = false; // No longer needed, logic is in WishlistButton

  // --- State for new UI ---
  final PageController _pageController = PageController();
  int _activePage = 0;
  // --- End State for new UI ---

  @override
  void initState() {
    super.initState();
    if (widget.product.price != null && widget.product.price!.isNotEmpty) {
      _updatePrice(_selectedSizeIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _updatePrice(int sizeIndex) {
    if (widget.product.price != null &&
        sizeIndex < widget.product.price!.length) {
      setState(() {
        _selectedSizeIndex = sizeIndex;
        _currentPrice = widget.product.price![sizeIndex];
        _originalPrice = _currentPrice / 0.85;
        _discountPercent =
            ((_originalPrice - _currentPrice) / _originalPrice * 100).round();
      });
    }
  }

  // _toggleWishlistBottomBar is no longer needed as _StickyBottomBar
  // now correctly uses the reusable WishlistButton widget.

  Color _getColorFromName(String colorName) {
    // This is the original, more detailed color map from WishProductDetail
    final map = {
      'white': Colors.white,
      'red': Colors.red.shade400,
      'pink': Colors.pink.shade200,
      'black': Colors.black87,
      'blue': Colors.blue.shade800,
      'grey': Colors.grey.shade700,
      'navy': const Color(0xFF000080),
    };
    return map[colorName.toLowerCase()] ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final id = widget.productId; // Using the dedicated productId from the constructor
    final isAdding = cartProvider.isUpdating(id);
    final isWished = wishlistProvider.isWishlisted(id);

    //
    // --- NEW UI STRUCTURE ---
    //
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarouselOverlay(context),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _DetailsBlock(
                        // Using "ZARA" as it was hardcoded in the original WishProductDetail
                        brand: "ZARA",
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
                          // Using both description and details from the original product
                          "${widget.product.description ?? 'No description.'}\n\n${widget.product.details ?? ''}",
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
              productId: id,
              isAdding: isAdding,
              isWished: isWished, // isWished is no longer used by _StickyBottomBar
              isWishlistLoading: false, // This is also not used
              onToggleWishlist: () {
                // This is not used by _StickyBottomBar, as it uses WishlistButton
              },
              onAddToBag: () async {
                // This is the *exact* logic from the original WishProductDetail
                try {
                  if (id.isEmpty) {
                    debugPrint("❌ Product ID is empty, cannot add to cart.");
                    return;
                  }

                  debugPrint("🛒 Adding product to cart...");
                  debugPrint("➡️ Product ID: $id");
                  debugPrint("➡️ Selected Size Index: $_selectedSizeIndex");
                  debugPrint("➡️ Selected Color Index: $_selectedColorIndex");

                  await cartProvider.addItemToCart(
                    id,
                    1,
                    _selectedSizeIndex,
                    _selectedColorIndex,
                  );

                  debugPrint("✅ Successfully added to cart!");
                  showCustomMessage(context, "Product added to cart");

                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                } catch (e) {
                  debugPrint("⚠️ Error while adding to cart: $e");
                  showCustomMessage(context, "Error: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  //
  // --- ALL HELPER METHODS FROM PRODUCT_DETAIL_SCREEN (PDP) ---
  //

  Widget _buildImageCarouselOverlay(BuildContext context) {
    final images = widget.product.images
        ?.map((e) => e.url ?? '')
        .where((u) => u.isNotEmpty)
        .toList() ??
        [];
    final height = MediaQuery.of(context).size.height * 0.5;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.isNotEmpty ? images.length : 1,
            onPageChanged: (i) => setState(() => _activePage = i),
            itemBuilder: (context, index) {
              final url = images.isNotEmpty ? images[index] : '';
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(color: Colors.grey[200]),
                errorWidget: (context, _, __) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  // Header heart: navigate to WishlistScreen
                  _CircleIconButton(
                    icon: Icons.favorite_border,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
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
    );
  }

  Widget _buildRatingChip() {
    return Container(
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
          SizedBox(width: 4),
          Text("25 Ratings",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    // This is the style from PDP
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
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }

  Widget _buildColorSelector() {
    // This style is from PDP, using the _getColorFromName from WishProductDetail
    final colorName = widget.product.color ?? 'Unknown';
    final colorValue = _getColorFromName(colorName);

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
              width: 40,
              height: 40,
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
    // This style is from PDP
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
                            style:
                            const TextStyle(fontWeight: FontWeight.w700)),
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
                            const Icon(Icons.star,
                                size: 12, color: Colors.white),
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

//
// --- ALL HELPER CLASSES FROM PRODUCT_DETAIL_SCREEN (PDP) ---
//

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
        Text(brand,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(name, style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
        const SizedBox(height: 100), // Padding for the bottom bar
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
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                // This correctly uses the reusable button, so the state
                // logic in the parent widget is no longer needed.
                child: WishlistButton(productId: productId)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isAdding ? null : onAddToBag,
              icon: isAdding
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.shopping_bag_outlined),
              label: Text(isAdding ? '' : 'Add to Bag'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ]),
      TextButton(onPressed: () {}, child: const Text('View all >')),
    ]);
  }
}