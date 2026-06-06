import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final int communityId;

  const CreatePostScreen({super.key, required this.communityId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  void _removeImage() => setState(() {
    _pickedImage = null;
    _imageBytes = null;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final post = await context.read<PostProvider>().createPost(
      currentUser.id,
      widget.communityId,
      _textCtrl.text.trim(),
      imageBytes: _imageBytes,
      imageName: _pickedImage?.name,
    );

    if (!mounted) return;
    if (post != null) {
      Navigator.pop(context, true);
    } else {
      final error = context.read<PostProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al publicar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PostProvider>().isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Container(
          decoration: isDesktop
              ? AppTheme.gradientDecoration(context)
              : BoxDecoration(color: AppTheme.scaffoldBg(context)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
              title: Text(
                'Nueva publicación',
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: isDesktop
                          ? const EdgeInsets.all(32)
                          : EdgeInsets.zero,
                      decoration: isDesktop
                          ? BoxDecoration(
                              color: AppTheme.cardBackground(context),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.borderColor(context),
                              ),
                            )
                          : const BoxDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Qué está pasando?',
                              style: TextStyle(
                                color: AppTheme.textPrimary(context),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _textCtrl,
                              maxLength: 1000,
                              maxLines: 6,
                              autofocus: true,
                              style: TextStyle(
                                color: AppTheme.textPrimary(context),
                              ),
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              decoration: InputDecoration(
                                hintText:
                                    'Escribe el contenido de tu post aquí...',
                                hintStyle: TextStyle(
                                  color: AppTheme.textSecondary(context),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.textSecondary(
                                      context,
                                    ).withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppTheme.accentBlue,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'El texto no puede estar vacío';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_imageBytes != null) ...[
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        Border.all(
                                          color: AppTheme.borderColor(context),
                                        ).wrap(
                                          Image.memory(
                                            _imageBytes!,
                                            width: double.infinity,
                                            height: 220,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: _removeImage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppTheme.textSecondary(context),
                                ),
                                label: Text(
                                  'Añadir imagen de portada',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary(
                                      context,
                                    ).withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  side: BorderSide(
                                    color: AppTheme.textSecondary(
                                      context,
                                    ).withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: AppTheme.headerBg(context),
                                ),
                              ),
                            ],
                            const SizedBox(height: 36),

                            Align(
                              alignment: Alignment.center,
                              child: FilledButton(
                                onPressed: isLoading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.buttonBlue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Publicar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on Border {
  Widget wrap(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: this,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
