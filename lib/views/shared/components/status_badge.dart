import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';

/// Status Badge for orders and products
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status.toLowerCase());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig(
          label: 'Pending',
          color: Colors.orange,
        );
      case 'confirmed':
        return _StatusConfig(
          label: 'Confirmed',
          color: Colors.blue,
        );
      case 'processing':
        return _StatusConfig(
          label: 'Processing',
          color: Colors.purple,
        );
      case 'shipped':
        return _StatusConfig(
          label: 'Shipped',
          color: Colors.indigo,
        );
      case 'delivered':
        return _StatusConfig(
          label: 'Delivered',
          color: AppColors.primary,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelled',
          color: Colors.red,
        );
      default:
        return _StatusConfig(
          label: status,
          color: AppColors.placeholder,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig({required this.label, required this.color});
}

/// Proxy Badge for imported products
class ProxyBadge extends StatelessWidget {
  final bool isSmall;

  const ProxyBadge({
    super.key,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_download,
            size: isSmall ? 12 : 14,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Imported',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

