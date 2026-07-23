import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tasks/add_task_screen.dart';
import 'screens/tasks/edit_task_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Premium Slate-based Material 3 Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primary,
            primary: AppConstants.primary,
            secondary: AppConstants.secondary,
            surface: AppConstants.surface,
            error: AppConstants.error,
          ),
          
          // Scaffold Background
          scaffoldBackgroundColor: AppConstants.background,
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppConstants.surface,
            foregroundColor: AppConstants.textPrimary,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppConstants.textSecondary),
          ),
          
          // Card Theme
          cardTheme: CardThemeData(
            color: AppConstants.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              side: const BorderSide(color: AppConstants.border, width: 1.0),
            ),
          ),
          
          // Typography
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),
            headlineSmall: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
            titleLarge: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
            titleMedium: TextStyle(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
            bodyLarge: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 16.0,
            ),
            bodyMedium: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 14.0,
            ),
            bodySmall: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 12.0,
            ),
            labelLarge: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Date Picker Theme (Material 3 overrides)
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: AppConstants.primary,
            headerForegroundColor: AppConstants.surface,
            dayStyle: const TextStyle(fontWeight: FontWeight.normal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
          ),
        ),
        
        // Navigation routes configuration
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-task': (context) => const AddTaskScreen(),
          '/edit-task': (context) => const EditTaskScreen(),
        },
      ),
    );
  }
}
