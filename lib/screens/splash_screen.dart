import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Small delay to present branding visual
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeAuth();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Productivity Checkmark Icon
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppConstants.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: AppConstants.accent,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              
              // App Title
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppConstants.surface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              
              // App Tagline
              Text(
                'Organize. Track. Achieve.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 100),
              
              // Loading Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
