import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/features/auth/presentation/pages/login_page.dart';
import 'package:urban_plant/features/auth/presentation/pages/register_page.dart';
import 'package:urban_plant/features/auth/presentation/pages/verify_email_page.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/pages/dashboard_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard: (_) => const AuthGuard(child: DashboardPage()),
  };
}

// Bungkus halaman yang butuh autentikasi dengan AuthGuard
class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    // Kalau status masih initial (app baru restart), jalankan initAuth
    final status = context.read<AuthProvider>().status;
    if (status == AuthStatus.initial) {
      context.read<AuthProvider>().initAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.loading || AuthStatus.initial => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => widget.child,
      AuthStatus.emailNotVerified => const VerifyEmailPage(),
      _ => const LoginPage(),
    };
  }
}

// Penggunaan di routes:
// dashboard: (_) => const AuthGuard(child: DashboardPage())
//            ↑ DashboardPage HANYA muncul jika status = authenticated

// SplashPage: cek token tersimpan, redirect otomatis
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().initAuth();
    if (!mounted) return;

    final status = context.read<AuthProvider>().status;
    if (status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
