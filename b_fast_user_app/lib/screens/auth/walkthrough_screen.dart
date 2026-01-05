import 'package:flutter/material.dart';

import '../auth_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- UPDATED: Onboarding Content Expanded to 5 Slides ---
  final List<Map<String, String>> onboardingData = [
    {
      "image": "https://images.unsplash.com/photo-1509319117193-57bab727e09d?auto=format&fit=crop&w=800&q=80",
      "title": "Discover Latest Trends",
      "description": "Explore curated collections and find the perfect outfit for any occasion, delivered in a flash."
    },
    {
      "image": "https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=800&q=80",
      "title": "Fast & Reliable Delivery",
      "description": "Get your favorite styles delivered to your doorstep faster than ever. Your wardrobe update is just a tap away."
    },
    {
      // --- FIX: New image for the third slide ---
      "image": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80",
      "title": "Your Style, Your Way",
      "description": "From chic accessories to essential outfits, build a look that's uniquely you."
    },
    {
      // --- ADDED: Fourth slide ---
      "image": "https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=800&q=80",
      "title": "Personalized For You",
      "description": "Get style recommendations tailored to your unique taste. The more you browse, the better it gets."
    },
    {
      // --- ADDED: Fifth slide ---
      "image": "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80",
      "title": "Join The Community",
      "description": "Share your looks, get inspired by others, and connect with fellow fashion lovers. Let's get started!"
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomAuthScreen()));
  }

  void _onNext() {
    if (_currentPage == onboardingData.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // --- ADDED: Function for the back button ---
  void _onBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return Image.network(
                onboardingData[index]['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 24,
            child: TextButton(
              onPressed: _onSkip,
              child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  onboardingData[_currentPage]['title']!,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  onboardingData[_currentPage]['description']!,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    // --- ADDED: Back Button (conditionally visible) ---
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _onBack,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    // Page Indicators
                    ...List.generate(onboardingData.length, (index) => _buildDot(index)),
                    const Spacer(),
                    // Next/Get Started Button
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6.0),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
