
import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../screens/order_details_screen.dart';

// ---------- Reusable UI primitives (copied from your reference) ----------

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Updated card using your model, same logic, reference UI ----------

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Safely pick the first item for name/image
    final Items? firstItem =
        (order.items != null && order.items!.isNotEmpty) ? order.items!.first : null;

    final String idText = order.sId?.toString().trim().isNotEmpty == true
        ? order.sId!.trim()
        : "Unknown ID";
    final String statusText =
        order.orderStatus?.toString().trim().isNotEmpty == true
            ? order.orderStatus!.trim()
            : "Unknown";
    final String modeText =
        order.deliveryMode?.toString().trim().isNotEmpty == true
            ? order.deliveryMode!.trim()
            : "N/A";
    final String totalText = "₹${order.total ?? 0}";
    final String productName =
        (firstItem?.name?.trim().isNotEmpty == true) ? firstItem!.name!.trim() : "Product";
    final String imageUrl =
        (firstItem?.image?.trim().isNotEmpty == true) ? firstItem!.image!.trim() : "";

    final String addressText = [
      order.address?.street?.trim(),
      order.address?.city?.trim(),
    ].where((s) => (s != null && s.isNotEmpty)).join(", ");
    final String safeAddress = addressText.isEmpty ? "No address" : addressText;

    return SoftCard(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + titles + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(imageUrl: imageUrl, fallbackText: productName),
                const SizedBox(width: 10),

                // Product title and id expand to take available space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      // Order ID as subdued subtitle with #
                      Text(
                        '#$idText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Status chip constrained to avoid overlap
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 96, maxWidth: 140),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Stat pills row (vehicle placeholder + mode + total)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const StatPill(icon: Icons.two_wheeler_outlined, label: ' '),
                StatPill(icon: Icons.local_shipping_outlined, label: modeText),
                StatPill(icon: Icons.payments_outlined, label: totalText),
              ],
            ),

            const SizedBox(height: 10),

            // Items container, showing item count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.black87),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${order.items?.length ?? 0} items',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Address row in monochrome
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    safeAddress,
                    style: const TextStyle(color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Circle avatar with safe NetworkImage handling and fallback initials
class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.fallbackText});

  final String imageUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder();
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.black12,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    final String initials = _initialsFromName(fallbackText);
    if (initials.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
      child: Icon(Icons.image_not_supported_outlined, color: Colors.white),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final chars = parts.take(2).map((p) => p.characters.first).join();
    return chars.toUpperCase();
  }
}