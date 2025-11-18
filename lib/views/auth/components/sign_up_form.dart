import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/validators.dart';
import 'already_have_accout.dart';
import 'sign_up_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  
  UserRole? _selectedRole;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.margin),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Account Type", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...UserRole.values.map((role) => RadioListTile<UserRole>(
              title: Text(role.displayName),
              subtitle: Text(role.description, style: const TextStyle(fontSize: 12)),
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            )).toList(),
            const SizedBox(height: AppDefaults.padding),
            const Text("Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: Validators.requiredWithFieldName('Name').call,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              validator: Validators.required.call,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppDefaults.padding),
            // Business information for Retailers and Wholesalers
            if (_selectedRole == UserRole.retailer || _selectedRole == UserRole.wholesaler) ...[
              const Text("Business Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _businessNameController,
                validator: Validators.requiredWithFieldName('Business Name').call,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),
              const Text("Business Address"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _businessAddressController,
                validator: Validators.requiredWithFieldName('Business Address').call,
                textInputAction: TextInputAction.next,
                maxLines: 2,
              ),
              const SizedBox(height: AppDefaults.padding),
            ],
            const Text("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: SvgPicture.asset(
                      AppIcons.eye,
                      width: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            SignUpButton(
              formKey: _formKey,
              selectedRole: _selectedRole,
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              passwordController: _passwordController,
              businessNameController: _businessNameController,
              businessAddressController: _businessAddressController,
            ),
            const AlreadyHaveAnAccount(),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}
