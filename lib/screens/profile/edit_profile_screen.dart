import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  XFile? _pickedImage;
  Uint8List? _imageBytes;
  late String _currentAvatarUrl;

  final _picker = ImagePicker();

  // Paleta de colores unificada y compartida de Flee
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameCtrl = TextEditingController(text: user.name);
    _bioCtrl = TextEditingController(text: user.bio);
    _currentAvatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
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
    final ok = await context.read<AuthProvider>().editProfile(
      _nameCtrl.text.trim(),
      _bioCtrl.text.trim(),
      imageBytes: _imageBytes,
      imageFileName: _pickedImage?.name,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al actualizar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAvatarPicker() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageBytes != null
                  ? CircleAvatar(
                      radius: 48,
                      backgroundImage: MemoryImage(_imageBytes!),
                    )
                  : UserAvatar(avatarUrl: _currentAvatarUrl, radius: 48),
            ),
            if (_imageBytes != null)
              GestureDetector(
                onTap: _removeImage,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: const BoxDecoration(
                    color: buttonBlue,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
            color: accentBlue,
          ),
          label: const Text(
            'Cambiar foto de perfil',
            style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
              'Editar perfil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                            // Selector de Avatar Centrado
                            Center(child: _buildAvatarPicker()),
                            const SizedBox(height: 28),

                            // Campo: Nombre
                            TextFormField(
                              controller: _nameCtrl,
                              maxLength: 100,
                              style: const TextStyle(color: Colors.white),
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              decoration: _inputDecoration(
                                label: 'Nombre',
                                icon: Icons.person_outlined,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Campo: Biografía
                            TextFormField(
                              controller: _bioCtrl,
                              maxLength: 500,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              decoration: _inputDecoration(
                                label: 'Biografía',
                                icon: Icons.info_outline,
                              ).copyWith(alignLabelWithHint: true),
                            ),
                            const SizedBox(height: 36),

                            // Botón de Enviar (Estilo Guardar cambios)
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: isDesktop ? null : double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: buttonBlue,
                                    foregroundColor: Colors.white,
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
                                          'Guardar cambios',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
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

  /// Helper homogeneizado para los inputs de Flee
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted),
      prefixIcon: Icon(icon, color: textMuted),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textMuted.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: accentBlue),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
