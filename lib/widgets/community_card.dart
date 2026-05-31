import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final bool isMember;
  final VoidCallback? onFollowTap;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
    required this.isMember,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.communityStatusColor(community.communityStatus);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    status: community.communityStatus,
                    color: statusColor,
                  ),
                ],
              ),
              if (community.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  community.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.communityEndLabel(community.endDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (onFollowTap != null)
                    _FollowButton(
                      isMember: isMember,
                      isActive: community.isActive,
                      onTap: onFollowTap!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  String get _label {
    switch (status) {
      case 'Active':
        return 'Activa';
      case 'Ghost':
        return 'Archivando';
      case 'Ended':
        return 'Finalizada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isMember;
  final bool isActive;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isMember,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isMember) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check, size: 14),
        label: const Text('Siguiendo', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return FilledButton.icon(
      onPressed: isActive ? onTap : null,
      icon: const Icon(Icons.add, size: 14),
      label: const Text('Unirse', style: TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
