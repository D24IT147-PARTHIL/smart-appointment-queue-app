import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'booking_screen.dart';
import 'status_screen.dart';
import 'appointment_list_screen.dart';
import 'search_screen.dart';
import 'admin_screen.dart';

/// Main layout with bottom navigation bar — 5 tabs matching the UI design
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BookingScreen(),
    StatusScreen(),
    AppointmentListScreen(),
    SearchScreen(),
    AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar matching QueueEase design
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            // Logo icon
            Container(
              padding: const EdgeInsets.all(4),
              child: const Text(
                '⟨⟩',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'QueueEase',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            onPressed: () {
              // Placeholder for refresh
            },
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
          // Status indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.completed,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],

      // Bottom Navigation matching the UI design
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.book_outlined, 'Book', 0),
                _buildNavItem(Icons.assignment_outlined, 'Status', 1),
                _buildNavItem(Icons.list_alt_outlined, 'List', 2),
                _buildNavItem(Icons.search, 'Search', 3),
                _buildNavItem(Icons.dashboard_outlined, 'Admin', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
