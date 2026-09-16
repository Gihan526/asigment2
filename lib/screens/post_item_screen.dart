import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../models/lost_item.dart';
import '../services/item_service.dart';
import '../theme/app_colors.dart';

/// Screen to create a new found item post or edit an existing one.
class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key, this.itemToEdit});

  /// If provided, screen will be in Edit mode; otherwise in Create mode.
  final LostItem? itemToEdit;

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ItemService _itemService = ItemService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contactController;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String? _statusMessage;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _contactController = TextEditingController(text: item?.contactInfo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Show modal to choose photo source (Camera or Gallery)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera/gallery: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Item Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(TablerIcons.camera, color: AppColors.blue),
                  ),
                  title: const Text('Take a photo with Camera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(TablerIcons.photo, color: AppColors.blue),
                  ),
                  title: const Text('Choose from Photo Gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Submit the post: upload photo to Firebase Storage and save to Realtime Database
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // In create mode, a photo is strictly required
    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo of the found item.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = _isEditing
          ? (_selectedImage != null ? 'Uploading new photo...' : 'Updating details...')
          : 'Uploading photo to Firebase Storage...';
    });

    try {
      if (_isEditing) {
        await _itemService.updateItem(
          originalItem: widget.itemToEdit!,
          title: _titleController.text,
          location: _locationController.text,
          description: _descriptionController.text,
          contactInfo: _contactController.text,
          newImageFile: _selectedImage,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() => _statusMessage = 'Saving to Realtime Database...');
        await _itemService.createItem(
          title: _titleController.text,
          location: _locationController.text,
          description: _descriptionController.text,
          contactInfo: _contactController.text,
          imageFile: _selectedImage!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item posted successfully!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Item Post' : 'Post Found Item',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Photo Picker Container
                _buildPhotoPicker(context),
                const SizedBox(height: 24),

                // 2. What is this item? (Title)
                Text(
                  'What did you find?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'e.g. Earbud, Blue Backpack, Scientific Calculator',
                    prefixIcon: const Icon(TablerIcons.tag, size: 20),
                    fillColor: colors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter what you found (e.g. Earbud)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Where was it found? (Location)
                Text(
                  'Where was it found?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'e.g. Lecture Room 5, Library 2nd floor, Cafeteria',
                    prefixIcon: const Icon(TablerIcons.map_pin, size: 20),
                    fillColor: colors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the place it was found';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. Description / Details (Optional)
                Text(
                  'Additional Details (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isLoading,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Color, condition, specific brand or markings...',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(TablerIcons.notes, size: 20),
                    ),
                    fillColor: colors.surface,
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Contact / Pickup instructions
                Text(
                  'Pickup & Contact Instructions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'e.g. Handed to Main Security Desk, or email me',
                    prefixIcon: const Icon(TablerIcons.info_circle, size: 20),
                    fillColor: colors.surface,
                  ),
                ),
                const SizedBox(height: 32),

                // Loading status indicator
                if (_isLoading && _statusMessage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit Button
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.lightPrimaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    icon: Icon(
                      _isEditing ? TablerIcons.check : TablerIcons.cloud_upload,
                      size: 20,
                    ),
                    label: Text(
                      _isEditing ? 'Save Changes' : 'Post Found Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Photo selection and preview container
  Widget _buildPhotoPicker(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasExistingImage = _isEditing && widget.itemToEdit!.imageUrl.isNotEmpty;
    final hasNewImage = _selectedImageBytes != null;

    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourcePicker,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (hasNewImage || hasExistingImage) ? colors.outline : colors.primary,
            width: (hasNewImage || hasExistingImage) ? 1.0 : 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // If new local image is picked
            if (hasNewImage)
              Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            // If editing and has existing Firebase Storage URL
            else if (hasExistingImage)
              Image.network(
                widget.itemToEdit!.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(TablerIcons.photo_off, size: 40, color: Colors.grey),
                ),
              )
            // Empty placeholder prompting user to upload
            else
              Container(
                color: colors.primary.withValues(alpha: 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        TablerIcons.camera_plus,
                        size: 32,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Picture of the Item',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to take photo or pick from gallery',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // Change Photo Badge overlay when image is present
            if (hasNewImage || hasExistingImage)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(TablerIcons.edit, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Change Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
