import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/enums/user_role.dart';
import '../../core/models/user_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../cart/cart_page.dart';
import '../home/home_page.dart';
import '../menu/menu_page.dart';
import '../profile/profile_page.dart';
import '../retailer/retailer_dashboard_page.dart';
import '../save/save_page.dart';
import '../wholesaler/wholesaler_dashboard_page.dart';
import 'components/app_navigation_bar.dart';

/// This page will route users to role-specific dashboards
class EntryPointUI extends StatefulWidget {
  const EntryPointUI({super.key});

  @override
  State<EntryPointUI> createState() => _EntryPointUIState();
}

class _EntryPointUIState extends State<EntryPointUI> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    
    print('=== DEBUG ENTRYPOINT ===');
    print('User loaded: ${user != null}');
    print('User role: ${user?.role.name}');
    print('User name: ${user?.name}');
    print('=== END DEBUG ===');
    
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      // If no user found, redirect to login
      if (_currentUser == null) {
        Future.microtask(() {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.loginOrSignup);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (_currentUser!.role) {
      case UserRole.customer:
        return const CustomerEntryPointUI();
      case UserRole.retailer:
        return const RetailerDashboardPage();
      case UserRole.wholesaler:
        return const WholesalerDashboardPage();
    }
  }
}

/// Customer Entry Point - Original entry point for customers
class CustomerEntryPointUI extends StatefulWidget {
  const CustomerEntryPointUI({super.key});

  @override
  State<CustomerEntryPointUI> createState() => _CustomerEntryPointUIState();
}

class _CustomerEntryPointUIState extends State<CustomerEntryPointUI> {
  /// Current Page
  int currentIndex = 0;

  /// On labelLarge navigation tap
  void onBottomNavigationTap(int index) {
    currentIndex = index;
    setState(() {});
  }

  /// All the pages
  List<Widget> pages = [
    const HomePage(),
    const MenuPage(),
    const CartPage(isHomePage: true),
    const SavePage(isHomePage: false),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: AppColors.scaffoldBackground,
            child: child,
          );
        },
        duration: AppDefaults.duration,
        child: pages[currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onBottomNavigationTap(2);
        },
        backgroundColor: AppColors.primary,
        child: SvgPicture.asset(AppIcons.cart),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onNavTap: onBottomNavigationTap,
      ),
    );
  }
}
