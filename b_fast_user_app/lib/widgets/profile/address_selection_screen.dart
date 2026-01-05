
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/models/address_model.dart';
import 'package:b_fast_user_app/providers/user_provider.dart';
import '../address/address_form_widget.dart';
import '../order/payment_selection.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String? storeId;
  final double totalPrice;

  const AddressSelectionScreen({
    super.key,
    required this.totalPrice,
    required this.storeId,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int _selectedAddressIndex = 0;

  void _showAddressForm(BuildContext context, {Addresses? existingAddress}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddressFormSheet(existingAddress: existingAddress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final addresses = userProvider.userDetails?.addresses ?? [];
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

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
        title: const Text('Select Address'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const SizedBox(height: 24),
              const Text(
                'SAVED ADDRESSES',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Text("No addresses found. Please add one."),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return _buildAddressItem(
                      address: address,
                      index: index,
                      isSelected: _selectedAddressIndex == index,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                ),
              const SizedBox(height: 24),
              _buildAddNewAddressButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStep('Bag', isComplete: true),
        const Expanded(child: Divider()),
        _buildStep('Address', isActive: true),
        const Expanded(child: Divider()),
        _buildStep('Payment'),
      ],
    );
  }

  Widget _buildStep(String title, {bool isActive = false, bool isComplete = false}) {
    final filled = isActive || isComplete;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: filled ? Colors.green : Colors.grey.shade300,
          child: isComplete
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : (isActive ? const CircleAvatar(radius: 4, backgroundColor: Colors.white) : null),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: filled ? Colors.black : Colors.grey,
            fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressItem({
    required Addresses address,
    required int index,
    required bool isSelected,
  }) {
    final fullAddress = "${address.street}, ${address.city}, ${address.state} - ${address.zip}";
    final phone = context.read<UserProvider>().userDetails?.phone ?? 'N/A';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Radio<int>(
                    value: index,
                    groupValue: _selectedAddressIndex,
                    onChanged: (int? value) {
                      setState(() => _selectedAddressIndex = value!);
                    },
                    activeColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.label ?? 'Address',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullAddress, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Phone: $phone', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSelected
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentSelectionScreen(
                              address: address,
                              totalPrice: widget.totalPrice,
                              storeId: widget.storeId,
                            ),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Deliver to this Address'),
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

  Widget _buildAddNewAddressButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddressForm(context),
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text(
        'Add New Address',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}
