import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class DevelopmentHomeScreen extends ConsumerStatefulWidget {
  const DevelopmentHomeScreen({super.key});

  @override
  ConsumerState<DevelopmentHomeScreen> createState() =>
      _DevelopmentHomeScreenState();
}

class _DevelopmentHomeScreenState extends ConsumerState<DevelopmentHomeScreen> {
  String _displayName = 'User';
  String _currentDate = '';
  int _selectedIndex = 0; // For bottom nav

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _currentDate = DateFormat('MM/dd').format(DateTime.now());
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null && meta['display_name'] != null) {
        // Check display_name first
        setState(() {
          _displayName = meta['display_name'];
        });
      } else if (meta != null && meta['first_name'] != null) {
        setState(() {
          _displayName = meta['first_name'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Light gray background
      body: Column(
        children: [
          // 1. Custom App Bar / Header
          _buildHeader(),

          // 2. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  _buildTimelineSection(),
                  const SizedBox(height: 20),
                  _buildNewsSection(),
                  // Ensure Recommendations sits at bottom or scrolls
                  _buildRecommendationsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/AdeliaHealth_white.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Icons
          _headerIcon(Icons.calendar_today_outlined),
          const SizedBox(width: 16),
          _headerIcon(Icons.mail_outline),
          const SizedBox(width: 16),
          _headerIcon(Icons.chat_bubble_outline),
          const SizedBox(width: 16),
          // Logout button instead of settings check
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            onPressed: () => _logout(),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
          // Avatar
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=1',
            ), // Placeholder
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 22);
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: const Color(0xFFF0F0F0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              'Good morning $_displayName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _currentDate,
            style: const TextStyle(fontSize: 18, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    // Dummy Data
    final events = [
      {'time': '09:00 AM', 'title': 'Meditation', 'subtitle': 'Find your seat'},
      {
        'time': '11:30 AM',
        'title': 'Hydration',
        'subtitle': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      },
      {
        'time': '03:00 PM',
        'title': 'Lorem ipsum dolor sit amet',
        'subtitle': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ...events.map((e) => _timelineItem(e)).toList(),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Show more',
                style: TextStyle(color: Color(0xFF00A9E0), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item['time']!,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['subtitle']!,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xFFCCCCCC),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF00A9E0), // Cyan/Blue background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'News',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 3 Columns Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _newsCard()),
              const SizedBox(width: 12),
              Expanded(child: _newsCard()),
              const SizedBox(width: 12),
              Expanded(child: _newsCard()),
            ],
          ),
          const SizedBox(height: 24),
          // See all button centered (under middle column)
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _newsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            height: 140, // Increased height
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lorem ipsum',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Removed const
                Text(
                  'Lorem ipsum dolor sit amet...',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations (13)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // List of recommendation items
            _recommendationItem('Lorem Ipsum dolor'),
            _recommendationItem('Lorem Ipsum dolor'),
            _recommendationItem('Lorem Ipsum dolor'),
          ],
        ),
      ),
    );
  }

  Widget _recommendationItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const Icon(Icons.add, color: Color(0xFF333333)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Bottom bar gray
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_outlined),
          _navItem(1, Icons.coronavirus_outlined), // Virus icon
          _navItem(2, Icons.format_list_bulleted),
          _navItem(3, Icons.flag_outlined),
          _navItem(4, Icons.apple_outlined), // Diet
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? AppColors.primary : const Color(0xFF666666),
      ),
    );
  }
}
