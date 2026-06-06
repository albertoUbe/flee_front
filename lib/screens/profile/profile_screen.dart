import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'plans_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final planProvider = context.watch<PlanProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    final currentPlan = planProvider.planById(user.planId);

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
                'Perfil',
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textSecondary(context),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
              ],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: isDesktop
                          ? BoxDecoration(
                              color: AppTheme.cardBackground(context),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.borderColor(context),
                              ),
                            )
                          : const BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                UserAvatar(
                                  avatarUrl: user.avatarUrl,
                                  radius: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary(context),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary(context),
                                    fontSize: 14,
                                  ),
                                ),
                                if (user.bio.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    user.bio,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary(
                                        context,
                                      ).withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 14),
                                _StatusChip(status: user.userStatus),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'CUENTA Y SUSCRIPCIÓN',
                              style: TextStyle(
                                color: AppTheme.textSecondary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildTile(
                            context: context,
                            icon: Icons.workspace_premium_outlined,
                            title: 'Plan actual',
                            subtitle: currentPlan?.name ?? 'Cargando...',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.textSecondary(context),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlansScreen(),
                              ),
                            ),
                          ),
                          _buildTile(
                            context: context,
                            icon: Icons.calendar_today_outlined,
                            title: 'Miembro desde',
                            subtitle: DateFormatter.formatDate(user.createdAt),
                          ),
                          _buildTile(
                            context: context,
                            icon: Icons.star_border_outlined,
                            title: 'Planes de suscripción',
                            subtitle: 'Explora opciones premium',
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.textSecondary(context),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlansScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'ZONA DE SEGURIDAD',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildTile(
                            context: context,
                            icon: Icons.logout,
                            title: 'Cerrar sesión',
                            titleColor: Colors.orangeAccent,
                            iconColor: Colors.orangeAccent,
                            onTap: _signOut,
                          ),
                          _buildTile(
                            context: context,
                            icon: Icons.delete_forever_outlined,
                            title: 'Eliminar cuenta',
                            titleColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                            onTap: _deleteAccount,
                          ),
                        ],
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

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.headerBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icon,
          color: iconColor ?? AppTheme.textSecondary(context),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppTheme.textPrimary(context),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 12,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  ThemeData _dialogTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.dialogBg(context),
        elevation: 0,
      ),
    );
  }

  ShapeBorder get _dialogShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1.0),
  );

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Theme(
        data: _dialogTheme(context),
        child: AlertDialog(
          shape: _dialogShape,
          title: Text(
            'Cerrar sesión',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            '¿Seguro que quieres cerrar sesión de tu cuenta?',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 16,
            right: 16,
            left: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.buttonBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Theme(
        data: _dialogTheme(context),
        child: AlertDialog(
          shape: _dialogShape,
          title: Text(
            'Eliminar cuenta',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Esta acción es permanente y destructiva. Se eliminarán todos tus datos de inmediato. ¿Continuar?',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 16,
            right: 16,
            left: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Eliminar definitivamente',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().deleteAccount();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'Active':
        color = const Color(0xFF4CAF50);
        label = 'Activo';
        break;
      case 'NotVerified':
        color = const Color(0xFFFF9800);
        label = 'Pendiente de verificación';
        break;
      case 'Banned':
        color = const Color(0xFFEF5350);
        label = 'Suspendido';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
