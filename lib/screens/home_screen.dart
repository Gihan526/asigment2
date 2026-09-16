import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/campus_mark.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_screen.dart';

/// The Home screen displayed after successful login.
/// Fetches the logged-in user's profile from Firebase Realtime Database.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  // State variables for user profile data from Realtime Database
  bool _isLoading = true;
  String _name = '';
  String _email = '';
  String _uid = '';
  String _createdAt = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Fetch user profile data stored in Firebase Realtime Database
  Future<void> _loadUserProfile() async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      _navigateToLogin();
      return;
    }

    setState(() {
      _uid = currentUser.uid;
      _email = currentUser.email ?? '';
      _name = currentUser.displayName ?? 'Student';
    });

    try {
      // Read user data from Realtime Database at /users/{uid}
      final data = await _authService.getUserProfile(currentUser.uid);
      if (data != null && mounted) {
        setState(() {
          _name = (data['name'] as String?) ?? _name;
          _email = (data['email'] as String?) ?? _email;
          _createdAt = (data['createdAt'] as String?) ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile from database: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Sign out the user and navigate back to the Login screen
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onToggleTheme: widget.onToggleTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const Center(child: CampusMark(width: 80, height: 70)),
                        const SizedBox(height: 16),
                        Text(
                          'FOUNDLY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome, $_name!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are signed in with Firebase Authentication & Realtime Database.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile Card showing Realtime Database data
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: colors.outline),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user_rounded,
                                          color: colors.primary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'User Profile Details',
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _ProfileRow(
                                      icon: TablerIcons.user,
                                      label: 'Name',
                                      value: _name,
                                    ),
                                    const Divider(height: 24),
                                    _ProfileRow(
                                      icon: TablerIcons.mail,
                                      label: 'Email',
                                      value: _email,
                                    ),
                                    const Divider(height: 24),
                                    _ProfileRow(
                                      icon: TablerIcons.id,
                                      label: 'User UID',
                                      value: _uid,
                                      isMonospace: true,
                                    ),
                                    if (_createdAt.isNotEmpty) ...[
                                      const Divider(height: 24),
                                      _ProfileRow(
                                        icon: TablerIcons.calendar,
                                        label: 'Joined',
                                        value: _createdAt.split('T').first,
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                        const SizedBox(height: 32),

                        // Log out button
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _logout,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.yellow,
                              foregroundColor: AppColors.lightPrimaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            icon: const Icon(TablerIcons.logout, size: 20),
                            label: const Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Theme Toggle button at top right
              Positioned(
                top: 10,
                right: 20,
                child: ThemeToggleButton(onPressed: widget.onToggleTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to display a row in the profile card
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
