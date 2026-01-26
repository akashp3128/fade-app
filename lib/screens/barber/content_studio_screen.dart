import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:io';

import '../../config/theme.dart';
import '../../config/routes.dart';

import '../../providers/auth_provider.dart';

class ContentStudioScreen extends ConsumerStatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  ConsumerState<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends ConsumerState<ContentStudioScreen> {
  // ... existing variables ...
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _mediaFile;
  bool _isVideo = false;
  bool _isPremium = false;
  bool _isUploading = false;
  bool _isCompressing = false;
  
  final ImagePicker _picker = ImagePicker();

  void _onPremiumToggled(bool value) {
    if (value) {
      // Check Stripe Status
      final userAsync = ref.read(currentUserProvider);
      final hasStripe = userAsync.value?.stripeAccountId != null;
      
      if (!hasStripe) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Connect Stripe'),
            content: const Text(
              'To post Premium Content and earn money, you must connect your bank account via Stripe.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to Stripe Setup
                  context.push(Routes.barberStripeSetup); 
                },
                child: const Text('Connect Now'),
              ),
            ],
          ),
        );
        return; // Do not set state to true
      }
    }
    
    setState(() => _isPremium = value);
  }

  // ... existing methods ...

  Future<void> _pickMedia({required bool video}) async {
    final XFile? media = video 
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
    
    if (media != null) {
      if (video) {
        // Compress Video
        setState(() => _isCompressing = true);
        
        try {
          final MediaInfo? info = await VideoCompress.compressVideo(
            media.path,
            quality: VideoQuality.MediumQuality, // 720p approx
            deleteOrigin: false,
            includeAudio: true,
          );

          if (info != null && info.file != null) {
            setState(() {
              _mediaFile = info.file;
              _isVideo = true;
            });
            // print('Original size: ${File(media.path).lengthSync()}');
            // print('Compressed size: ${info.file!.lengthSync()}');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Compression failed: $e')),
          );
        } finally {
          setState(() => _isCompressing = false);
        }
      } else {
        // Handle Image
        setState(() {
          _mediaFile = File(media.path);
          _isVideo = false;
        });
      }
    }
  }

  Future<void> _uploadContent() async {
    if (!_formKey.currentState!.validate() || _mediaFile == null) return;

    setState(() => _isUploading = true);

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isUploading = false);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Success'),
          content: const Text('Your content has been uploaded successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.pop(); // Go back to dashboard
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Content Studio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _uploadContent,
            child: _isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Preview / Picker
              GestureDetector(
                onTap: () {
                  _showMediaPickerOptions(context);
                },
                child: Container(
                  height: 300,
                  width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(AppRadius.lg),
                                      border: Border.all(color: AppColors.divider),
                                      image: _mediaFile != null && !_isVideo
                                          ? DecorationImage(
                                              image: FileImage(_mediaFile!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _isCompressing
                                        ? Container(
                                            color: Colors.black54,
                                            child: const Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(color: AppColors.accent),
                                                  SizedBox(height: AppSpacing.md),
                                                  Text(
                                                    'Compressing Video...',
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : _mediaFile == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add_a_photo, size: 48, color: AppColors.textSecondary),
                                                  const SizedBox(height: AppSpacing.md),
                                                  Text(
                                                    'Tap to upload photo or video',
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                          color: AppColors.textSecondary,
                                                        ),
                                                  ),
                                                ],
                                              )
                                            : _isVideo
                                                ? const Center(
                                                    child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                                                  )
                                                : null,
                                  ),
                  
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
              
              // Caption
              TextFormField(
                controller: _captionController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  alignLabelWithHint: true,
                  hintText: 'Describe this look...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a caption';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Tags / Services
              Text('Linked Services', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _ServiceChip(label: 'Skin Fade', isSelected: true),
                  _ServiceChip(label: 'Beard Trim', isSelected: false),
                  _ServiceChip(label: 'Line Up', isSelected: false),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Premium Toggle
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: _isPremium ? AppColors.accent : AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.stars, color: _isPremium ? AppColors.accent : AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.md),
                            const Text('Premium Content'),
                          ],
                        ),
                        Switch(
                          value: _isPremium,
                          onChanged: _onPremiumToggled,
                          activeColor: AppColors.accent,
                        ),
                      ],
                    ),
                    if (_isPremium) ...[
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (Optional)',
                          prefixText: '\$ ',
                          helperText: 'Leave empty for Subscriber Only',
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

  void _showMediaPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickMedia(video: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Choose Video'),
            onTap: () {
              Navigator.pop(context);
              _pickMedia(video: true);
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  
  const _ServiceChip({required this.label, required this.isSelected});

  @override
  State<_ServiceChip> createState() => _ServiceChipState();
}

class _ServiceChipState extends State<_ServiceChip> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _selected,
      onSelected: (val) => setState(() => _selected = val),
      selectedColor: AppColors.accent.withOpacity(0.2),
      checkmarkColor: AppColors.accent,
    );
  }
}
