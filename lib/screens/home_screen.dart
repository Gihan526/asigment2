import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../models/lost_item.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';
import '../theme/app_colors.dart';
import '../widgets/campus_mark.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'item_detail_screen.dart';
import 'login_screen.dart';
import 'post_item_screen.dart';

/// The primary Campus Lost & Found screen.
/// Displays real-time feed of found items with
/// quick item details, and button to report/post a newly found item.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ItemService _itemService = ItemService();
  Stream<List<LostItem>>? _cachedItemsStream;

  // Initialize on first use, including states preserved during hot reload.
  // Reuse the stream when the theme rebuilds the UI.
  Stream<List<LostItem>> get _itemsStream =>
      _cachedItemsStream ??= _itemService.getItemsStream();

  // User Profile state
  String _name = '';
  String _email = '';
  String _uid = '';
  String _createdAt = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load current user profile from Cloud Firestore
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
      final data = await _authService.getUserProfile(currentUser.uid);
      if (data != null && mounted) {
        setState(() {
          _name = (data['name'] as String?) ?? _name;
          _email = (data['email'] as String?) ?? _email;
          _createdAt = (data['createdAt'] as String?) ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Sign out the user and navigate back to Login
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

  /// Open profile bottom sheet modal
  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: colors.primary.withValues(alpha: 0.12),
                      child: Icon(TablerIcons.user, size: 28, color: colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: TablerIcons.id,
                  label: 'User UID',
                  value: _uid,
                  isMonospace: true,
                ),
                if (_createdAt.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ProfileRow(
                    icon: TablerIcons.calendar,
                    label: 'Joined',
                    value: _createdAt.split('T').first,
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _logout();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    icon: const Icon(TablerIcons.logout, size: 18),
                    label: const Text(
                      'Log out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Open Post screen to add a newly found item
  Future<void> _openPostItemScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostItemScreen()),
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
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              const CampusMark(width: 34, height: 30),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOUNDLY',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Campus Lost & Found',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ThemeToggleButton(
              onPressed: widget.onToggleTheme,
              size: 42.0,
            ),
            const SizedBox(width: 8),
            ProfileActionButton(
              onPressed: _showProfileModal,
              size: 42.0,
              name: _name,
            ),
            const SizedBox(width: 16),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openPostItemScreen,
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.lightPrimaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          icon: const Icon(TablerIcons.plus, size: 20),
          label: const Text(
            'Post Found Item',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<List<LostItem>>(
            stream: _itemsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(TablerIcons.alert_circle, size: 40, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Failed to load items: ${snapshot.error}'),
                      ],
                    ),
                  ),
                );
              }

              final allItems = snapshot.data ?? [];

              // Empty State
              if (allItems.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            TablerIcons.box_off,
                            size: 40,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No found items reported yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Found something on campus? Post it to help the owner.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // List of items
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: allItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return _buildItemCard(context, item);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, LostItem item) {
    final colors = Theme.of(context).colorScheme;
    final isMyPost = item.userId == _uid;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image with overlay badges
            Stack(
              children: [
                Hero(
                  tag: 'item-image-${item.id}',
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: (MediaQuery.sizeOf(context).width *
                                    MediaQuery.devicePixelRatioOf(context))
                                .round(),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: colors.surface,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colors.surface,
                              child: const Center(
                                child: Icon(TablerIcons.photo_off, size: 36, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: colors.surface,
                            child: const Center(
                              child: Icon(TablerIcons.photo, size: 36, color: Colors.grey),
                            ),
                          ),
                  ),
                ),

                // Top Left: Status badge (Available vs Claimed)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isClaimed
                          ? Colors.black.withValues(alpha: 0.75)
                          : const Color(0xFFFBC200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.isClaimed ? 'Claimed' : 'Available',
                      style: TextStyle(
                        color: item.isClaimed
                            ? Colors.white
                            : AppColors.lightPrimaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Top Right: "My Post" badge
                if (isMyPost)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(TablerIcons.user_check, size: 12, color: AppColors.lightPrimaryText),
                          SizedBox(width: 4),
                          Text(
                            'My Post',
                            style: TextStyle(
                              color: AppColors.lightPrimaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Location badge
                  Row(
                    children: [
                      Icon(TablerIcons.map_pin, size: 15, color: colors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Optional description snippet
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
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
