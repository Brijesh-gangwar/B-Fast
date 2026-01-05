

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../widgets/category/category_item_list.dart';

class CategoryFilterScreen extends StatefulWidget {
  const CategoryFilterScreen({super.key});

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  String? selectedCategory;
  final List<String> selectedTags = [];
  bool _isLoading = false;

  // ✅ Categories with image and label
  final List<Map<String, String>> categories = [
    {'imageUrl': 'https://images.unsplash.com/photo-1618886614638-80e3c103d31a', 'label': "Men"},
    {'imageUrl': 'https://images.unsplash.com/photo-1483985988355-763728e1935b', 'label': "Women"},
    {'imageUrl': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f', 'label': 'Accessories'},
    {'imageUrl': 'https://images.unsplash.com/photo-1524805444758-089113d48a6d', 'label': 'Watches'},
    {'imageUrl': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=800&q=80', 'label': 'Shoes'},
    {'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80', 'label': 'Electronics'},
  ];

  // ✅ Tags by category
  final Map<String, List<String>> tagsByCategory = {
    "Men": ["Shirts", "Jeans", "Shoe", "Fashion"],
    "Women": ["Dresses", "Tops", "Shoes", "New"],
    "Accessories": ["Bags", "Jewelry", "Sunglasses"],
    "Watches": ["Smartwatches", "Luxury", "Casual"],
    "Shoes": ["Sneakers", "Formal", "Sandals"],
    "Electronics": ["Mobile", "Laptop", "Headphones"],
  };

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first['label'];
  }

  Future<void> _applyFilters() async {
    if (selectedCategory == null) return;
    final provider = Provider.of<ProductProvider>(context, listen: false);

    provider.setFilters(
      category: selectedCategory!,
      tags: selectedTags.isNotEmpty ? List<String>.from(selectedTags) : null,
    );

    // Start 10-second timeout
    bool navigated = false;
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !navigated && _isLoading) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Failed to get products. Please try again."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    try {
      await provider.refreshCategoryProducts(selectedCategory!);
      if (!mounted) return;
      navigated = true;

      // ✅ Stop loader before navigating
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryItemsScreen(category: selectedCategory!),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTagsForCategory = tagsByCategory[selectedCategory] ?? [];

    return Stack(
      children: [
        Scaffold(
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
            title: const Text('Categories'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Category image tabs
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat['label'] == selectedCategory;
                    return GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                selectedCategory = cat['label'];
                                selectedTags.clear(); // reset tags when category changes
                              });
                            },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: CachedNetworkImage(
                                imageUrl: cat['imageUrl']!,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 80,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  cat['label']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected ? Colors.black : Colors.grey[700],
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Tags",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // 🔹 Tags for selected category

              Expanded(
  child: GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, // ✅ 4 items per row
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      mainAxisExtent: 100, // adjust height of each grid cell
    ),
    itemCount: selectedTagsForCategory.length,
    itemBuilder: (context, index) {
      final tag = selectedTagsForCategory[index];
      final isSelected = selectedTags.contains(tag);

      return GestureDetector(
        onTap: _isLoading
            ? null
            : () async {
                setState(() {
                  selectedTags
                    ..clear() // ✅ Only one tag active at a time
                    ..add(tag);
                  _isLoading = true;
                });
                await _applyFilters(); // ✅ Apply immediately
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 254, 253, 253)
                : Colors.white,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: const AssetImage('assets/images/Logo.png'),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 6),
              Text(
                tag,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),

            ],
          ),
        ),

        // 🔹 Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          ),
      ],
    );
  }
}

