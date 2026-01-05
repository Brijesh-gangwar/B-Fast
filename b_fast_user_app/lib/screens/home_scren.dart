
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/product/Product_card.dart';
import 'wishlist_screen.dart';
import '../widgets/category/category_item_list.dart';

class HomeScren extends StatefulWidget {
  const HomeScren({super.key});

  @override
  State<HomeScren> createState() => _HomeScrenState();
}

class _HomeScrenState extends State<HomeScren> {
  final ScrollController _scrollController = ScrollController();

  // Search state (UI-only; no backend/provider changes)
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Product> _filtered = [];

  // Category chip selection (UI-only)
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initial data fetching (unchanged)
    Future.microtask(() {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.homeProducts.isEmpty) {
        productProvider.fetchHomeProducts();
      }
      context.read<WishlistProvider>().fetchWishlist();
      context.read<UserProvider>().fetchUserDetails();
      context.read<OrderProvider>().fetchOrders();
      context.read<CartProvider>().fetchCartItems();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Infinite scroll listener (unchanged)
  void _onScroll() {
    final provider = context.read<ProductProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !provider.isLoading &&
        !provider.isDone) {
      provider.fetchMoreHomeProducts();
    }
  }

  // Local filter that matches across Product fields
  void _applyFilter(List<Product> source, String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _filtered = [];
      });
      return;
    }

    bool matches(Product p) {
      final name = p.name?.toLowerCase() ?? '';
      final category = p.category?.toLowerCase() ?? '';
      final color = p.color?.toLowerCase() ?? '';
      final subCategory = p.subCategory?.toLowerCase() ?? '';
      final tags = (p.tags ?? []).map((e) => e.toLowerCase()).join(' ');
      final storeName = p.store.storeName?.toLowerCase() ?? '';
      return name.contains(query) ||
          category.contains(query) ||
          color.contains(query) ||
          subCategory.contains(query) ||
          tags.contains(query) ||
          storeName.contains(query);
    }

    final results = source.where(matches).toList();
    setState(() {
      _query = query;
      _filtered = results;
    });
  }

  // UI-only: tap on category icon
  void _onCategoryTapped(int index) async {
    setState(() {
      _selectedCategoryIndex = index;
    });
    // Intentionally no backend calls here.
    // CHANGE: Navigate to category products with category-only filter
    final mapping = [
      'All',
      'Women',
      'Men',
      'Accessories',
      'Watches',
      'Shoes',
      'Electronics',
    ];
    final selected = mapping[index];
    if (selected == 'All') return;

    final provider = context.read<ProductProvider>();
    provider.setFilters(category: selected, tags: null);
    await provider.refreshCategoryProducts(selected);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryItemsScreen(category: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final products = provider.homeProducts;

          if (products.isEmpty && provider.isLoading) {
            return _buildInitialShimmer();
          }

          if (products.isEmpty && provider.isDone) {
            return const Center(child: Text("No products available."));
          }

          // Which list to show
          final visible = _query.isEmpty ? products : _filtered;

          return RefreshIndicator(
            onRefresh: provider.refreshHomeProducts,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (_query.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildPromoCarousel(products.take(3).toList()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // INSERTED: Categories scroller between banner and New Arrivals
                  SliverToBoxAdapter(child: _buildCategoryIcons()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: _buildCenteredSectionHeader(
                        'New Arrivals', 'Grab the Fresh Stuff'),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child:
                        _buildNewArrivalsList(products.skip(3).take(6).toList()),
                  ),
                  // const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  // SliverToBoxAdapter(child: _buildBrandsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                SliverToBoxAdapter(
                  child: _buildCenteredSectionHeader(
                      _query.isEmpty ? 'B FAST Picks' : 'Search Results',
                      _query.isNotEmpty ? 'Matching products' : ''),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                if (_query.isNotEmpty && visible.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'No matching products',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: visible[index]),
                      childCount: visible.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: provider.isLoading && products.isNotEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }


  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);
  final user = userProvider.userDetails;

  // Single source of truth for gaps
  const double kActionGap = 12;

  return PreferredSize(
    preferredSize: const Size.fromHeight(130.0),
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  // Functional search field (filters locally)
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        final provider = context.read<ProductProvider>();
                        _applyFilter(provider.homeProducts, val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _query.isEmpty
                            ? const Icon(Icons.mic, color: Colors.grey)
                            : IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  final provider = context.read<ProductProvider>();
                                  _applyFilter(provider.homeProducts, '');
                                },
                              ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: kActionGap), // equal gap 1
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 26,
                      color: Colors.black87,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: kActionGap), // equal gap 2
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      size: 26,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    splashRadius: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivered to',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        (user?.addresses?.isNotEmpty == true)
                            ? '${user!.addresses!.first.street}, ${user.addresses!.first.city}'
                            : 'Your Address',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  // PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
  //   final userProvider = Provider.of<UserProvider>(context);
  //   final user = userProvider.userDetails;

  //   // Consistent gaps: 12px between search and both icons; icons visually aligned
  //   const double kActionGap = 12;

  //   return PreferredSize(
  //     preferredSize: const Size.fromHeight(130.0),
  //     child: AppBar(
  //       automaticallyImplyLeading: false,
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       flexibleSpace: SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Column(
  //             children: [
  //               const SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   // Functional search field (filters locally)
  //                   Expanded(
  //                     child: TextField(
  //                       controller: _searchController,
  //                       onChanged: (val) {
  //                         final provider = context.read<ProductProvider>();
  //                         _applyFilter(provider.homeProducts, val);
  //                       },
  //                       decoration: InputDecoration(
  //                         hintText: 'Search',
  //                         prefixIcon:
  //                             const Icon(Icons.search, color: Colors.grey),
  //                         suffixIcon: _query.isEmpty
  //                             ? const Icon(Icons.mic, color: Colors.grey)
  //                             : IconButton(
  //                                 icon: const Icon(Icons.close,
  //                                     color: Colors.grey),
  //                                 onPressed: () {
  //                                   _searchController.clear();
  //                                   final provider =
  //                                       context.read<ProductProvider>();
  //                                   _applyFilter(provider.homeProducts, '');
  //                                 },
  //                               ),
  //                         filled: true,
  //                         fillColor: Colors.grey[200],
  //                         contentPadding:
  //                             const EdgeInsets.symmetric(vertical: 0),
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(30.0),
  //                           borderSide: BorderSide.none,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   IconButton(
  //                     icon: const Icon(
  //                       Icons.notifications_none_rounded,
  //                       size: 26, // slightly reduced for visual balance
  //                       color: Colors.black87,
  //                     ),
  //                     onPressed: () {},
  //                     padding: EdgeInsets.zero,
  //                     constraints:
  //                         const BoxConstraints(minWidth: 40, minHeight: 40),
  //                     splashRadius: 22,
  //                   ),
  //                   const SizedBox(width:2),
  //                   IconButton(
  //                     icon: const Icon(
  //                       Icons.favorite_border_rounded,
  //                       size: 26,
  //                       color: Colors.black87,
  //                     ),
  //                     onPressed: () => Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (_) => const WishlistScreen()),
  //                     ),
  //                     padding: EdgeInsets.zero,
  //                     constraints:
  //                         const BoxConstraints(minWidth: 40, minHeight: 40),
  //                     splashRadius: 18,
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   // Location icon: bolder presence
  //                   const Icon(
  //                     Icons.location_on,
  //                     // filled variant looks bolder than outlined
  //                     color: Colors.black,
  //                     size: 20,
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const Text(
  //                         'Delivered to',
  //                         style: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.w600, // slightly bolder
  //                         ),
  //                       ),
  //                       Text(
  //                         (user?.addresses?.isNotEmpty == true)
  //                             ? '${user!.addresses!.first.street}, ${user.addresses!.first.city}'
  //                             : 'Your Address',
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 15,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Promo carousel
  Widget _buildPromoCarousel(List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 336,
        child: Center(child: Text("No promotions available.")),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
      child: SizedBox(
        width: 343,
        height: 400,
        child: PageView.builder(
          controller: PageController(viewportFraction: 1.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final imageUrl = product.images?.isNotEmpty == true
                ? (product.images!.first.url ?? '')
                : '';

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.withOpacity(0.6), width: 0.6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),

                    // Gradient overlay (bottom → black)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120, // adjust gradient height as needed
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom text over gradient
                    const Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Text(
                        'Super Sale - Discount Up to 50%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
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

  // Centered section header
  Widget _buildCenteredSectionHeader(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Left-aligned header for Brand section
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Horizontal New Arrivals list
  Widget _buildNewArrivalsList(List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 256,
            height: 230,
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(product: product),
          );
        },
      ),
    );
  }

  // // Brands section
  // Widget _buildBrandsSection() {
  //   final brands = [
  //     'https://download.logo.wine/logo/Under_Armour/Under_Armour-Logo.wine.png',
  //     'https://download.logo.wine/logo/Nike%2C_Inc./Nike%2C_Inc.-Logo.wine.png',
  //     'https://download.logo.wine/logo/New_Balance/New_Balance-Logo.wine.png',
  //     'https://download.logo.wine/logo/Converse_(shoe_company)/Converse_(shoe_company)-Logo.wine.png',
  //     'https://download.logo.wine/logo/Dolce_%26_Gabbana/Dolce_%26_Gabbana-Logo.wine.png',
  //   ];
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader('Shop by Brand', 'Top Fashion Brands'),
  //       const SizedBox(height: 12),
  //       SizedBox(
  //         height: 80,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           itemCount: brands.length,
  //           itemBuilder: (context, index) {
  //             final brandLogoUrl = brands[index];
  //             return Container(
  //               width: 120,
  //               margin: const EdgeInsets.only(right: 12),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(color: Colors.grey[300]!, width: 1.0),
  //               ),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(11),
  //                 child: CachedNetworkImage(
  //                   imageUrl: brandLogoUrl,
  //                   fit: BoxFit.contain,
  //                   placeholder: (context, url) => Shimmer.fromColors(
  //                     baseColor: Colors.grey[300]!,
  //                     highlightColor: Colors.grey[100]!,
  //                     child: Container(color: Colors.white),
  //                   ),
  //                   errorWidget: (context, error, stackTrace) {
  //                     return const Icon(Icons.error_outline, color: Colors.grey);
  //                   },
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // INSERTED: Category icons scroller (UI-only)
  Widget _buildCategoryIcons() {
    final categories = [
      {'imageUrl': 'assets/images/Logo.png', 'label': 'All'},
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1483985988355-763728e1935b',
        'label': "Women"
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1618886614638-80e3c103d31a',
        'label': "Men"
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1572635196237-14b3f281503f',
        'label': 'Accessories'
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
        'label': 'Watches'
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=800&q=80',
        'label': 'Shoes'
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
        'label': 'Electronics'
      },
    ];
    return SizedBox(
      height: 95,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => _onCategoryTapped(index),
            child: _CategoryIcon(
              imageUrl: cat['imageUrl'] as String,
              label: cat['label'] as String,
              isSelected: _selectedCategoryIndex == index,
            ),
          );
        },
      ),
    );
  }

  // Shimmer
  Widget _buildInitialShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo skeleton
            Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Categories skeleton
            SizedBox(
              height: 95,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 50, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 20,
                width: 150,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Category Icon pill
class _CategoryIcon extends StatelessWidget {
  final String imageUrl;
  final String label;
  final bool isSelected;

  const _CategoryIcon({
    required this.imageUrl,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.black : Colors.grey[300]!;
    final textColor = isSelected ? Colors.black : Colors.grey[700]!;

    final bool isAsset = imageUrl.startsWith('assets/');

    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: isAsset
              ? Image.asset(imageUrl, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (c, _) => Container(color: Colors.white),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
