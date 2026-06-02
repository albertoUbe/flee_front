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

  // Paleta de colores unificada de Flee
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Nueva comunidad',
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
                      padding: isDesktop
                          ? const EdgeInsets.all(32)
                          : EdgeInsets.zero,
                      decoration: isDesktop
                          ? BoxDecoration(
                              color: bgDark.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            )
                          : const BoxDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo: Nombre de la Comunidad
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
                                label: 'Nombre de la comunidad',
                                icon: Icons.group_outlined,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'El nombre es obligatorio';
                                if (v.trim().length < 3)
                                  return 'Mínimo 3 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Campo: Descripción
                            TextFormField(
                              controller: _descCtrl,
                              maxLength: 500,
                              maxLines: 4,
                              style: const TextStyle(color: Colors.white),
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              decoration: _inputDecoration(
                                label: 'Descripción',
                                icon: Icons.description_outlined,
                              ).copyWith(alignLabelWithHint: true),
                            ),
                            const SizedBox(height: 28),

                            // Sección de Duración
                            const Text(
                              'Duración',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'La comunidad dejará de aceptar nuevas publicaciones al finalizar la duración.',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 16),

                            // Selector de semanas (ChoiceChips)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _durations.map((weeks) {
                                final selected = _durationWeeks == weeks;
                                return ChoiceChip(
                                  label: Text(
                                    weeks == 1 ? '1 semana' : '$weeks semanas',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : textMuted,
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: buttonBlue,
                                  backgroundColor: bgDark,
                                  checkmarkColor: Colors.white,
                                  showCheckmark: false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: selected
                                          ? buttonBlue
                                          : textMuted.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _durationWeeks = weeks),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 40),

                            // Botón de Enviar (Centrado y ajustado al contenido)
                            Align(
                              alignment: Alignment
                                  .center, // Modificado a centro global
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
                                    ), // Un poco más de padding para que luzca mejor centrado
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
                                          'Crear comunidad',
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

  /// Helper para la decoración homogénea de los inputs
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted),
      prefixIcon: Icon(icon, color: textMuted),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: textMuted),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: accentBlue),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
