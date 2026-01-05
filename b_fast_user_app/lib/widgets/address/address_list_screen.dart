
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/address_model.dart';
import 'package:b_fast_user_app/providers/address_provider.dart';
import 'package:b_fast_user_app/providers/user_provider.dart';

import '../snackbar_fxn.dart';
import 'address_form_widget.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  // Helper method to get an icon based on the address label
  IconData _getAddressIcon(String? label) {
    if (label == null) return Icons.location_on_outlined;
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  // Method to show the new AddressFormSheet (NO CHANGE)
  void _showAddressForm(BuildContext context, {Addresses? existingAddress}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allows sheet to curve
      builder: (_) => AddressFormSheet(existingAddress: existingAddress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final addresses = userProvider.userDetails?.addresses ?? [];
    final ValueNotifier<String?> deletingAddressId = ValueNotifier(null);

    return Scaffold(
      appBar: AppBar(
        // --- UI Update: Centered and Styled Title ---
        title: Text(
          "My Addresses",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // --- UI Update: Changed to white background ---
      backgroundColor: Colors.white,
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? _buildEmptyState(context)
          : ValueListenableBuilder<String?>(
        valueListenable: deletingAddressId,
        builder: (_, deletingId, __) {
          return ListView.builder(
            // --- UI Update: Added padding ---
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressCard(
                  context, address, deletingId, deletingAddressId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(context),
        // --- UI Update: Changed to black (consistent action color) ---
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- UI Update: Restyled Empty State ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            "No Addresses Found",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the '+' button to add your first address.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // --- UI Update: Restyled Address Card ---
  Widget _buildAddressCard(
      BuildContext context,
      Addresses address,
      String? deletingId,
      ValueNotifier<String?> deletingAddressId,
      ) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Label
                Row(
                  children: [
                    Icon(_getAddressIcon(address.label),
                        color: Colors.black, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      address.label ?? 'Address',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                // Action Buttons (Edit/Delete)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: Colors.blueGrey[600], size: 22),
                      onPressed: () =>
                          _showAddressForm(context, existingAddress: address),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: deletingId == address.addressId
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.red),
                      )
                          : Icon(Icons.delete_outline,
                          color: Colors.red[400], size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: deletingId == address.addressId
                          ? null
                          : () async {
                        // --- NO CHANGE TO LOGIC ---
                        deletingAddressId.value = address.addressId;
                        try {
                          await Provider.of<AddressProvider>(context,
                              listen: false)
                              .deleteAddress(address.addressId!);
                          if (context.mounted) {
                            showCustomMessage(
                                context, "Address deleted successfully");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showCustomMessage(context, "Delete failed: $e");
                          }
                        } finally {
                          deletingAddressId.value = null;
                        }
                        // --- END NO CHANGE ---
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // Full Address Text
            Text(
              "${address.street}, ${address.city}",
              style: TextStyle(
                  fontSize: 15, color: Colors.grey[800], height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              "${address.state} ${address.zip}, ${address.country}",
              style: TextStyle(
                  fontSize: 15, color: Colors.grey[800], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}