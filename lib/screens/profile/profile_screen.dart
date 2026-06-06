import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';
import 'edit_profile_screen.dart';
import 'plans_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

  static const _fleeUtilBase = 'https://flee-util.vercel.app';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthProvider>().refreshUser();
    }
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
              ? const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.3,
                    colors: [gradientStart, gradientEnd],
                    stops: [0.0, 1.0],
                  ),
                )
              : const BoxDecoration(color: bgDark),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: textMuted),
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
                              color: bgDark.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                if (user.bio.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    user.bio,
                                    style: const TextStyle(
                                      color: Colors.white70,
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
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'CUENTA Y SUSCRIPCIÓN',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Plan actual',
                            subtitle: currentPlan?.name ?? 'Cargando...',
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: textMuted,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlansScreen(),
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.calendar_today_outlined,
                            title: 'Miembro desde',
                            subtitle: DateFormatter.formatDate(user.createdAt),
                          ),
                          _buildTile(
                            icon: Icons.star_border_outlined,
                            title: 'Planes de suscripción',
                            subtitle: 'Explora opciones premium',
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: textMuted,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlansScreen(),
                              ),
                            ),
                          ),
                          if (user.userStatus == 'NotVerified') ...[
                            const SizedBox(height: 24),
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'VERIFICACIÓN',
                                style: TextStyle(
                                  color: Color(0xFF42A5F5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            _buildTile(
                              icon: Icons.verified_user_outlined,
                              title: 'Verificar cuenta',
                              subtitle: 'Activa tu cuenta desde el navegador',
                              iconColor: accentBlue,
                              trailing: const Icon(
                                Icons.open_in_new,
                                size: 14,
                                color: textMuted,
                              ),
                              onTap: () async {
                                final url = Uri.parse(
                                  '$_fleeUtilBase/verify?userId=${user.id}',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
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
                            icon: Icons.logout,
                            title: 'Cerrar sesión',
                            titleColor: Colors.orangeAccent,
                            iconColor: Colors.orangeAccent,
                            onTap: _signOut,
                          ),
                          _buildTile(
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
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color titleColor = Colors.white,
    Color iconColor = textMuted,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: textMuted, fontSize: 12),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  ThemeData _dialogTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      dialogTheme: const DialogThemeData(backgroundColor: bgDark, elevation: 0),
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
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            '¿Seguro que quieres cerrar sesión de tu cuenta?',
            style: TextStyle(color: textMuted, fontSize: 14),
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
                foregroundColor: textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: buttonBlue,
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
          title: const Text(
            'Eliminar cuenta',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Esta acción es permanente y destructiva. Se eliminarán todos tus datos de inmediato. ¿Continuar?',
            style: TextStyle(color: textMuted, fontSize: 14),
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
                foregroundColor: textMuted,
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
