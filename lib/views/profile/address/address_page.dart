import 'package:flutter/material.dart';
import "package:flutter_svg/svg.dart";

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Delivery Address',
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(AppDefaults.margin),
        padding: const EdgeInsets.all(AppDefaults.padding),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Stack(
          children: [
            ListView.separated(
              itemBuilder: (context, index) {
                // Different Indian addresses for each index
                final addresses = [
                  {
                    'label': 'Home',
                    'address': '42, MG Road, Connaught Place, New Delhi - 110001',
                    'number': '+91 98765 43210',
                  },
                  {
                    'label': 'Office',
                    'address': '15/3, Brigade Road, Bangalore, Karnataka - 560001',
                    'number': '+91 98765 43211',
                  },
                  {
                    'label': 'Parents House',
                    'address': '78, Marine Drive, Nariman Point, Mumbai - 400021',
                    'number': '+91 98765 43212',
                  },
                  {
                    'label': 'Work',
                    'address': '23, Park Street, Kolkata, West Bengal - 700016',
                    'number': '+91 98765 43213',
                  },
                  {
                    'label': 'Other',
                    'address': '56, Anna Salai, T Nagar, Chennai - 600017',
                    'number': '+91 98765 43214',
                  },
                ];
                
                return AddressTile(
                  label: addresses[index]['label']!,
                  address: addresses[index]['address']!,
                  number: addresses[index]['number']!,
                  isActive: index == 0,
                );
              },
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const Divider(thickness: 0.2),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.newAddress);
                },
                backgroundColor: AppColors.primary,
                splashColor: AppColors.primary,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.label,
    required this.number,
    required this.isActive,
  });

  final String address;
  final String label;
  final String number;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppRadio(isActive: isActive),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                )
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(AppIcons.edit),
                constraints: const BoxConstraints(),
                iconSize: 14,
              ),
              const SizedBox(height: AppDefaults.margin / 2),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(AppIcons.deleteOutline),
                constraints: const BoxConstraints(),
                iconSize: 14,
              ),
            ],
          )
        ],
      ),
    );
  }
}
