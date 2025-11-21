import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/order_model.dart';
import 'package:intl/intl.dart';
import 'status_badge.dart';

/// Order Card for displaying orders in lists
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool showCustomerName;
  final bool showRetailerName;
  final bool showWholesalerName;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showCustomerName = false,
    this.showRetailerName = false,
    this.showWholesalerName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.borderRadius,
        side: BorderSide(color: AppColors.gray.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDefaults.borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id.substring(order.id.length - 6)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  StatusBadge(status: order.status.name, isSmall: true),
                ],
              ),
              const SizedBox(height: 8),
              if (showCustomerName && order.userId != null)
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value: order.userId ?? '',
                ),
              if (showRetailerName && order.retailerId != null)
                _InfoRow(
                  icon: Icons.store_outlined,
                  label: 'Retailer',
                  value: order.retailerId ?? '',
                ),
              if (showWholesalerName && order.wholesalerId != null)
                _InfoRow(
                  icon: Icons.warehouse_outlined,
                  label: 'Wholesaler',
                  value: order.wholesalerId ?? '',
                ),
              _InfoRow(
                icon: Icons.shopping_bag_outlined,
                label: 'Items',
                value: '${order.items.length} items',
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: _formatDate(order.createdAt),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.placeholder,
                        ),
                  ),
                  Text(
                    '\$${order.finalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.placeholder),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

