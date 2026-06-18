import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() => runApp(const AafedApp());

class AafedApp extends StatelessWidget {
  const AafedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أفريقيا للتعليم والتنمية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // اتجاه عربي RTL
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
