import 'package:flutter/material.dart' show BoxConstraints, BuildContext, Colors, CrossAxisAlignment, EdgeInsets, FontWeight, IconButton, Padding, Row, SizedBox, Spacer, State, StatefulWidget, Text, TextDecoration, Theme, Widget, WidgetsBinding;
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';

class PriceAndQuantityRow extends StatefulWidget {
  const PriceAndQuantityRow({
    super.key,
    required this.currentPrice,
    required this.orginalPrice,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  final double currentPrice;
  final double orginalPrice;
  final int quantity;
  final void Function()? onIncrement;
  final void Function()? onDecrement;

  @override
  State<PriceAndQuantityRow> createState() => _PriceAndQuantityRowState();
}

class _PriceAndQuantityRowState extends State<PriceAndQuantityRow> {
  int quantity = 1;

  onQuantityIncrease() {
    if (widget.onIncrement != null) {
      widget.onIncrement!();
    } else {
      quantity++;
      setState(() {});
    }
  }

  onQuantityDecrease() {
    if (widget.onDecrement != null) {
      widget.onDecrement!();
    } else {
      if (quantity > 1) {
        quantity--;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayQuantity = widget.onIncrement != null ? widget.quantity : quantity;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        /* <---- Price -----> */
        Text(
          '₹${widget.orginalPrice.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
              ),
        ),
        const SizedBox(width: AppDefaults.padding),
        Text(
          '₹${widget.currentPrice.toStringAsFixed(0)}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        const Spacer(),

        /* <---- Quantity -----> */
        Row(
          children: [
            IconButton(
              onPressed: onQuantityIncrease,
              icon: SvgPicture.asset(AppIcons.addQuantity),
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$displayQuantity',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            IconButton(
              onPressed: onQuantityDecrease,
              icon: SvgPicture.asset(AppIcons.removeQuantity),
              constraints: const BoxConstraints(),
            ),
          ],
        )
      ],
    );
  }
}
