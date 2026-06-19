import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/product_provider.dart';
import 'providers/bill_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VyparSathiApp());
}

class VyparSathiApp extends StatelessWidget {
  const VyparSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'VyparSathi',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0A2540),
                primary: const Color(0xFF0A2540),
                secondary: const Color(0xFF2ECC71),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0A2540),
                brightness: Brightness.dark,
                primary: const Color(0xFF1A3A5A),
                secondary: const Color(0xFF2ECC71),
              ),
            ),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
