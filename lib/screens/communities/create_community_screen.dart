import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _durationWeeks = 4;

  static const _durations = [1, 2, 4, 8, 12, 24];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final community = await context.read<CommunityProvider>().createCommunity(
          currentUser.id,
          _nameCtrl.text.trim(),
          _descCtrl.text.trim(),
          _durationWeeks,
        );

    if (!mounted) return;
    if (community != null) {
      Navigator.pop(context, true);
    } else {
      final error = context.read<CommunityProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al crear comunidad'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CommunityProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva comunidad')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la comunidad',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Duración',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'La comunidad dejará de aceptar nuevas publicaciones al finalizar la duración.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _durations.map((weeks) {
                    final selected = _durationWeeks == weeks;
                    return ChoiceChip(
                      label: Text(
                        weeks == 1 ? '1 semana' : '$weeks semanas',
                      ),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _durationWeeks = weeks),
                    );
                  }).toList(),
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
                        : const Text('Crear comunidad'),
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
