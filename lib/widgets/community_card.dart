import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final bool isMember;
  final VoidCallback? onFollowTap;

  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);

  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
    required this.isMember,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.communityStatusColor(
      community.communityStatus,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                  style: const TextStyle(color: textMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 13,
                    color: textMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.communityEndLabel(community.endDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted.withValues(alpha: 0.7),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
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
        icon: const Icon(Icons.check, size: 13),
        label: const Text('Siguiendo', style: TextStyle(fontSize: 11)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF42A5F5),
          side: const BorderSide(color: Color(0xFF42A5F5), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return FilledButton.icon(
      onPressed: isActive ? onTap : null,
      icon: const Icon(Icons.add, size: 13),
      label: const Text('Unirse', style: TextStyle(fontSize: 11)),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
