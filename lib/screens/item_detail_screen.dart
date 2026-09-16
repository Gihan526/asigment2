import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../models/lost_item.dart';
import '../services/item_service.dart';
import '../theme/app_colors.dart';
import 'post_item_screen.dart';

/// Screen displaying the full details of a found item, with options to claim,
/// edit, or delete if the current user created the post.
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final LostItem item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late LostItem _item;
  final ItemService _itemService = ItemService();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  bool get _isAuthor {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return currentUid != null && currentUid == _item.userId;
  }

  /// Toggle item claimed status (available vs claimed)
  Future<void> _toggleClaimed() async {
    setState(() => _isActionLoading = true);
    try {
      await _itemService.toggleClaimedStatus(
        itemId: _item.id,
        isClaimed: _item.isClaimed,
      );
      setState(() {
        _item = _item.copyWith(isClaimed: !_item.isClaimed);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _item.isClaimed
                  ? 'Item marked as claimed / returned!'
                  : 'Item marked as available.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  /// Delete the item post and its photo from Firebase
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this post?'),
        content: const Text(
          'This will permanently remove the item details and delete the uploaded photo from Firebase Storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isActionLoading = true);
      try {
        await _itemService.deleteItem(_item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully.')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isActionLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete item: $e')),
          );
        }
      }
    }
  }

  /// Open edit screen
  Future<void> _editItem() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PostItemScreen(itemToEdit: _item),
      ),
    );

    if (result == true && mounted) {
      // Re-fetch or pop back to refresh feed
      Navigator.pop(context, true);
    }
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year} at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          if (_isAuthor) ...[
            IconButton(
              tooltip: 'Edit Post',
              icon: const Icon(TablerIcons.edit),
              onPressed: _isActionLoading ? null : _editItem,
            ),
            IconButton(
              tooltip: 'Delete Post',
              icon: const Icon(TablerIcons.trash, color: Colors.redAccent),
              onPressed: _isActionLoading ? null : _confirmDelete,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Full Item Image
              Hero(
                tag: 'item-image-${_item.id}',
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: colors.surface,
                  child: _item.imageUrl.isNotEmpty
                      ? Image.network(
                          _item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: colors.surface,
                            child: const Center(
                              child: Icon(TablerIcons.photo_off, size: 48, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: colors.surface,
                          child: const Center(
                            child: Icon(TablerIcons.photo, size: 48, color: Colors.grey),
                          ),
                        ),
                ),
              ),

              // 2. Main Content Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _item.isClaimed
                                ? Colors.grey.withValues(alpha: 0.15)
                                : const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _item.isClaimed
                                    ? TablerIcons.circle_check
                                    : TablerIcons.circle_dot,
                                size: 14,
                                color: _item.isClaimed
                                    ? Colors.grey
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _item.isClaimed ? 'Claimed by Owner' : 'Available',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _item.isClaimed
                                      ? Colors.grey
                                      : const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(_item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Item Title ("What is this thing?")
                    Text(
                      _item.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Location Card ("Where was it found?")
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(TablerIcons.map_pin, color: colors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FOUND AT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _item.location,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description / Details (if present)
                    if (_item.description.isNotEmpty) ...[
                      Text(
                        'Details & Condition',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Text(
                          _item.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Pickup / Contact instructions
                    if (_item.contactInfo.isNotEmpty) ...[
                      Text(
                        'Pickup & Contact Instructions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(TablerIcons.info_circle, size: 20, color: AppColors.yellow),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _item.contactInfo,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Finder Info Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.primary.withValues(alpha: 0.1),
                            child: Icon(TablerIcons.user, color: colors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Posted by',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _item.userName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                if (_item.userEmail.isNotEmpty)
                                  Text(
                                    _item.userEmail,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Author Action Buttons
                    if (_isAuthor) ...[
                      // Mark as Claimed / Available Toggle Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isActionLoading ? null : _toggleClaimed,
                          icon: Icon(
                            _item.isClaimed
                                ? TablerIcons.refresh
                                : TablerIcons.check,
                            size: 20,
                          ),
                          label: Text(
                            _item.isClaimed
                                ? 'Mark as Available Again'
                                : 'Mark as Claimed by Owner',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Edit Post Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isActionLoading ? null : _editItem,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.lightPrimaryText,
                          ),
                          icon: const Icon(TablerIcons.edit, size: 20),
                          label: const Text(
                            'Edit Post Details',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
