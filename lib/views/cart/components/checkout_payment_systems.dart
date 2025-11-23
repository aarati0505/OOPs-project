import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'checkout_payment_card_tile.dart';

class PaymentSystem extends StatefulWidget {
  const PaymentSystem({
    super.key,
    this.onPaymentMethodChanged,
  });

  final Function(String)? onPaymentMethodChanged;

  @override
  State<PaymentSystem> createState() => _PaymentSystemState();
}

class _PaymentSystemState extends State<PaymentSystem> {
  String _selectedPayment = 'cod'; // Default to Cash on Delivery

  @override
  void initState() {
    super.initState();
    // Notify parent of initial selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPaymentMethodChanged?.call(_selectedPayment);
    });
  }

  void _selectPayment(String method) {
    setState(() {
      _selectedPayment = method;
    });
    widget.onPaymentMethodChanged?.call(method);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Payment System',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Cash on Delivery (Default and Working)
              PaymentCardTile(
                label: 'Cash On Delivery',
                icon: AppIcons.cashOnDelivery,
                onTap: () => _selectPayment('cod'),
                isActive: _selectedPayment == 'cod',
              ),
              // Razorpay Payment Option
              PaymentCardTile(
                label: 'Razorpay',
                icon: AppIcons.razorpay,
                onTap: () => _selectPayment('razorpay'),
                isActive: _selectedPayment == 'razorpay',
              ),
              PaymentCardTile(
                label: 'Master Card',
                icon: AppIcons.masterCard,
                onTap: () => _selectPayment('mastercard'),
                isActive: _selectedPayment == 'mastercard',
              ),
              PaymentCardTile(
                label: 'Paypal',
                icon: AppIcons.paypal,
                onTap: () => _selectPayment('paypal'),
                isActive: _selectedPayment == 'paypal',
              ),
            ],
          ),
        )
      ],
    );
  }
}
