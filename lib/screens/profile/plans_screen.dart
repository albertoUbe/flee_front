import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/plan_model.dart';
import '../../widgets/loading_indicator.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Planes de suscripción')),
      body: planProvider.isLoading
          ? const LoadingIndicator()
          : planProvider.plans.isEmpty
              ? const Center(child: Text('No hay planes disponibles'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: planProvider.plans.length,
                  itemBuilder: (_, i) => _PlanCard(
                    plan: planProvider.plans[i],
                    isActive: currentUser?.planId == planProvider.plans[i].id,
                  ),
                ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isActive;

  const _PlanCard({required this.plan, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive ? colorScheme.primary : null,
                      ),
                ),
                if (isActive)
                  Chip(
                    label: const Text('Tu plan', style: TextStyle(fontSize: 11)),
                    backgroundColor: colorScheme.primaryContainer,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.price == 0
                  ? 'Gratis'
                  : '${plan.price.toStringAsFixed(2)} € / mes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: plan.price == 0 ? Colors.green : colorScheme.primary,
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
              text: 'Hasta ${plan.maxTime} semana${plan.maxTime == 1 ? '' : 's'} de duración',
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
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
