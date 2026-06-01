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
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Cambiar foto de perfil'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(child: _buildAvatarPicker()),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioCtrl,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Biografía',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
