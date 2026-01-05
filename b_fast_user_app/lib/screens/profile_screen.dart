
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/providers/user_provider.dart';
import 'package:b_fast_user_app/screens/auth_screen.dart';
import 'package:b_fast_user_app/screens/order_screen.dart';
import 'package:b_fast_user_app/screens/wishlist_screen.dart';
import 'package:b_fast_user_app/widgets/address/address_list_screen.dart';
import 'package:b_fast_user_app/widgets/profile/phone_edit_screen.dart';

import '../main.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userDetails;

     
  // Logout functionality
  Future<void> logout() async {
    final authService = AuthService();
    CustomAuthScreen.disposeClerkListener();
    final auth = ClerkAuth.of(context);
    await auth.signOut();
    await authService.clearUserId();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SplashOrHome()),
      );
    }
  }

    // A list of profile options to keep the build method clean
    final List<Map<String, dynamic>> profileOptions = [
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Orders',
        'subtitle': 'Track, return or reorder',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
       },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Addresses',
        'subtitle': 'Manage delivery locations',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())),
      },
      
      {
        'icon': Icons.favorite_border,
        'title': 'Wishlist',
        'subtitle': 'Saved items',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
       },
      // {
      //   'icon': Icons.notifications_none,
      //   'title': 'Notifications',
      //   'subtitle': 'Promos and alerts',
      //   'onTap': () { /* Navigate to Notifications Screen */ },
      // },
      {
        'icon': Icons.headset_mic_outlined,
        'title': 'Help Center',
        'subtitle': 'FAQs and support',
        'onTap': () { /* Navigate to Help Center */ },
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'subtitle': 'Preferences and permissions',
        'onTap': () { /* Navigate to Settings Screen */ },
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'LOGOUT',
        'subtitle': 'Tap to logout',
        'onTap': () async {
          await logout();
          },
      },
    ];


   


    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("Could not load profile."))
              : SafeArea(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: profileOptions.length + 1, // +1 for the header
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // The first item is the profile header
                        return _buildProfileHeader(
                          context,
                          name: user.name ?? 'Guest',
                          subtitle: '${user.email ?? 'No email'}',
                        
                        );
                      }
                      // The rest are the profile options
                      final option = profileOptions[index - 1];
                      return _buildProfileOption(
                        icon: option['icon'],
                        title: option['title'],
                        subtitle: option['subtitle'],
                        onTap: option['onTap'],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, {required String name, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneEditScreen()));
            },
          ),
        ],
      ),
    );
  }

  // *** This widget is now updated to be a Card ***
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 20,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Colors.black54, size: 26),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}