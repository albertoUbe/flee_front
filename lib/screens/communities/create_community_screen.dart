import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
            title: Text(
              'Nueva comunidad',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isDesktop
                ? AppTheme.gradientDecoration(context)
                : BoxDecoration(color: AppTheme.scaffoldBg(context)),
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
                            TextFormField(
                              controller: _nameCtrl,
                              maxLength: 100,
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
                              decoration: _inputDecoration(
                                context: context,
                                label: 'Nombre de la comunidad',
                                icon: Icons.group_outlined,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                if (v.trim().length < 3) {
                                  return 'Mínimo 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _descCtrl,
                              maxLength: 500,
                              maxLines: 4,
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
                              decoration: _inputDecoration(
                                context: context,
                                label: 'Descripción',
                                icon: Icons.description_outlined,
                              ).copyWith(alignLabelWithHint: true),
                            ),
                            const SizedBox(height: 28),

                            Text(
                              'Duración',
                              style: TextStyle(
                                color: AppTheme.textPrimary(context),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'La comunidad dejará de aceptar nuevas publicaciones al finalizar la duración.',
                              style: TextStyle(
                                color: AppTheme.textSecondary(context),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),

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
                                          : AppTheme.textSecondary(context),
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedColor: AppTheme.buttonBlue,
                                  backgroundColor: AppTheme.scaffoldBg(context),
                                  checkmarkColor: Colors.white,
                                  showCheckmark: false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: selected
                                          ? AppTheme.buttonBlue
                                          : AppTheme.textSecondary(
                                              context,
                                            ).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _durationWeeks = weeks),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 40),

                            Align(
                              alignment: Alignment.center,
                              child: FilledButton(
                                onPressed: isLoading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.buttonBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
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

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary(context)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.accentBlue),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
