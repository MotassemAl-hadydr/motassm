import 'package:electricity_management/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/meter_provider.dart';
import 'providers/meter_reading_provider.dart';
import 'providers/subscriber_provider.dart';
import 'screens/auth/login_screen.dart';
import 'providers/bill_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriberProvider()),
        ChangeNotifierProvider(create: (_) => MeterProvider()),
        ChangeNotifierProvider(create: (_) => MeterReadingProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'نظام إدارة الكهرباء',

        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Cairo',

          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),

          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        ),

        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // 1. إذا كان التطبيق يتحقق من الجلسة في الخلفية، نعرض مؤشر تحميل
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // 2. إذا وجدنا أن المستخدم مسجل مسبقاً، نوجهه للرئيسية فوراً
            if (authProvider.currentUser != null) {
              return const HomeScreen();
            }
            // 3. إذا لم يكن مسجلاً، نوجهه لشاشة تسجيل الدخول
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
