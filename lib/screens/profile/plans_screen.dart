import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/plan_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
            title: Text(
              'Planes de suscripción',
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
                child: planProvider.isLoading
                    ? const LoadingIndicator()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground(context),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.borderColor(context),
                              ),
                            ),
                            child: planProvider.plans.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Text(
                                        'No hay planes disponibles',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary(
                                            context,
                                          ),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Elige tu nivel',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary(context),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Desbloquea más funciones y expande tus límites en las comunidades.',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary(
                                            context,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: planProvider.plans.length,
                                        itemBuilder: (_, i) => _PlanCard(
                                          plan: planProvider.plans[i],
                                          isActive:
                                              currentUser?.planId ==
                                              planProvider.plans[i].id,
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
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isActive;

  const _PlanCard({required this.plan, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.headerBg(
          context,
        ).withValues(alpha: isActive ? 0.8 : 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.accentBlue : AppTheme.borderColor(context),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isActive
                        ? AppTheme.accentBlue
                        : AppTheme.textPrimary(context),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.buttonBlue.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Tu plan',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.price == 0
                  ? 'Gratis'
                  : '${plan.price.toStringAsFixed(2)} € / mes',
              style: TextStyle(
                color: plan.price == 0
                    ? const Color(0xFF4CAF50)
                    : AppTheme.textPrimary(context),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FeatureRow(
              icon: Icons.group_outlined,
              text:
                  '${plan.maxCommunities} comunidad${plan.maxCommunities == 1 ? '' : 'es'} por mes',
            ),
            const SizedBox(height: 8),
            _FeatureRow(
              icon: Icons.timer_outlined,
              text:
                  'Hasta ${plan.maxTime} semana${plan.maxTime == 1 ? '' : 's'} de duración',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textPrimary(context).withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
