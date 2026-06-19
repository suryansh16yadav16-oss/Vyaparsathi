import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_card.dart';
import 'stock_screen.dart';
import 'billing_screen.dart';
import 'voice_order_screen.dart';
import 'sales_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeContent(),
    const StockScreen(),
    const BillingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final date = DateFormat('EEEE, d MMMM y').format(now);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Good $greeting ☀️',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome to VyparSathi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              CustomCard(
                icon: Icons.inventory,
                title: 'My Stock',
                color: Color(0xFF0A2540),
                route: StockScreen(),
              ),
              CustomCard(
                icon: Icons.attach_money,
                title: "Today's Sales",
                color: Color(0xFF2ECC71),
                route: SalesScreen(),
              ),
              CustomCard(
                icon: Icons.receipt_long,
                title: 'Billing',
                color: Color(0xFF0A2540),
                route: BillingScreen(),
              ),
              CustomCard(
                icon: Icons.mic,
                title: 'Voice Order',
                color: Color(0xFF2ECC71),
                route: VoiceOrderScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
