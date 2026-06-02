import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';

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

  // Paleta de colores unificada y compartida de Flee
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

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

        return Scaffold(
          backgroundColor: bgDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Nueva publicación',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentBlue,
                            ),
                          ),
                        )
                      : const Text(
                          'Publicar',
                          style: TextStyle(
                            color: accentBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isDesktop
                ? const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.3,
                      colors: [gradientStart, gradientEnd],
                      stops: [0.0, 1.0],
                    ),
                  )
                : const BoxDecoration(color: bgDark),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: bgDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Qué está pasando?',
                              style: TextStyle(
                                color: Colors.white,
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
                              style: const TextStyle(color: Colors.white),
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
                                hintStyle: const TextStyle(color: textMuted),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: textMuted.withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: accentBlue,
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
                                          color: Colors.white.withValues(
                                            alpha: 0.06,
                                          ),
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
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: textMuted,
                                ),
                                label: const Text(
                                  'Añadir imagen de portada',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  side: BorderSide(
                                    color: textMuted.withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                            ],
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
