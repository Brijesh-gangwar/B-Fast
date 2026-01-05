

// import 'package:flutter/material.dart';
// import 'dashboard_screen.dart';
// import '../../../orders/presentation/screens/orders_screen.dart';
// import '../../../profile/presentation/screens/profile_screen.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   // Your screens list remains the same
//   static const List<Widget> _screens = [
//     DashboardScreen(),
//     OrderScreen(),
//     AgentDetailsScreen(), 
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey[600],
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Orders"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    OrderScreen(),
    AgentDetailsScreen(),
  ];

  void _onSelect(int i) {
    setState(() => _selectedIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    // Design constants to mirror the UI shell
    const double navHeight = 60; // roomy for 32–34dp icons and indicator [web:12]
    const double shellRadius = 28; // rounded pill container [web:12]
    const double shellElevation = 10; // subtle lift/shadow [web:12]

    final Color barBg = Colors.black.withOpacity(0.94); // rich dark base [web:12]
    final Color iconDefault = Colors.white.withOpacity(0.78); // softer idle [web:12]
    final Color iconSelected = Colors.white; // bright active [web:12]
    final Color indicator = Colors.white.withOpacity(0.14); // soft selection pill [web:12]

    return Scaffold(
      extendBody: true, // content can draw behind floating bar [web:12]
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12), // consistent inset [web:12]
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // side breathing room [web:12]
          child: _FloatingShell(
            color: barBg,
            radius: shellRadius,
            elevation: shellElevation,
            child: SizedBox(
              height: navHeight, // lock height to theme [web:12][web:1]
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: navHeight, // match wrapper [web:1]
                  backgroundColor: Colors.transparent, // shell provides color [web:1]
                  elevation: 0, // flat inside shell [web:1]
                  indicatorColor: indicator, // subtle pill indicator [web:12]
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // icon-only [web:1]
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected); // stateful size/color [web:1]
                    return IconThemeData(
                      size: selected ? 34 : 32, // slightly larger when active [web:1]
                      color: selected ? iconSelected : iconDefault, // contrast on dark [web:12]
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex, // sync with stack index [web:1]
                  animationDuration: const Duration(milliseconds: 300), // smooth [web:1]
                  onDestinationSelected: _onSelect, // local tab switch [web:15]
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined), // 32 via theme [web:1]
                      selectedIcon: Icon(Icons.home_rounded), // 34 via theme [web:1]
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded), // orders [web:1]
                      selectedIcon: Icon(Icons.grid_view_rounded), // same glyph [web:1]
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline), // profile [web:1]
                      selectedIcon: Icon(Icons.person), // active [web:1]
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded/elevated pill container providing the black background and white ripple. [web:12]
class _FloatingShell extends StatelessWidget {
  const _FloatingShell({
    required this.child,
    required this.color,
    required this.radius,
    required this.elevation,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent, // Material draws color [web:1]
      elevation: elevation, // drop shadow [web:12]
      borderRadius: BorderRadius.circular(radius), // pill shape [web:12]
      clipBehavior: Clip.antiAlias, // smooth edges [web:12]
      child: Material(
        color: color, // bar background [web:12]
        borderRadius: BorderRadius.circular(radius), // match parent [web:12]
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.white.withOpacity(0.22), // white ripple [web:12]
            highlightColor: Colors.white.withOpacity(0.10), // highlight [web:12]
            hoverColor: Colors.white.withOpacity(0.06), // hover [web:12]
          ),
          child: child, // NavigationBar [web:1]
        ),
      ),
    );
  }
}