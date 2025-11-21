import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_images.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/local_auth_service.dart';
import '../../core/themes/app_themes.dart';
import 'dialogs/verified_dialogs.dart';

class NumberVerificationPage extends StatefulWidget {
  const NumberVerificationPage({super.key});

  @override
  State<NumberVerificationPage> createState() => _NumberVerificationPageState();
}

class _NumberVerificationPageState extends State<NumberVerificationPage> {
  Map<String, dynamic>? _signupData;
  final GlobalKey<_OTPTextFieldsState> _otpFieldsKey = GlobalKey<_OTPTextFieldsState>();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get signup data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _signupData = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  margin: const EdgeInsets.all(AppDefaults.margin),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: AppDefaults.borderRadius,
                  ),
                  child: Column(
                    children: [
                      const NumberVerificationHeader(),
                      OTPTextFields(
                        key: _otpFieldsKey,
                        onOtpComplete: (otp) => _handleOtpVerification(otp),
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      const ResendButton(),
                      const SizedBox(height: AppDefaults.padding),
                      VerifyButton(
                        onVerify: () => _handleVerifyButton(),
                      ),
                      const SizedBox(height: AppDefaults.padding),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOtpVerification(String otp) async {
    if (_signupData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup data not found. Please try again.')),
      );
      return;
    }

    // Simple OTP validation (any 4 digits work in demo mode)
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP code')),
      );
      return;
    }

    try {
      // Parse role from string
      final roleString = _signupData!['role'] as String? ?? 'customer';
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.customer,
      );

      // Save user to local storage (demo mode - no API call)
      await LocalAuthService.saveLoginState(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _signupData!['name'] as String? ?? 'User',
        email: _signupData!['email'] as String? ?? '',
        phoneNumber: _signupData!['phoneNumber'] as String? ?? '',
        role: role, // Use the role from signup form
      );

      // Show success dialog and navigate
      if (mounted) {
        showGeneralDialog(
          barrierLabel: 'Dialog',
          barrierDismissible: false,
          context: context,
          pageBuilder: (ctx, anim1, anim2) => VerifiedDialog(userRole: role),
          transitionBuilder: (ctx, anim1, anim2, child) => ScaleTransition(
            scale: anim1,
            child: child,
          ),
        );
      }
    } catch (e) {
      // If save fails, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }


  void _handleVerifyButton() {
    // Collect OTP from text fields
    final otpState = _otpFieldsKey.currentState;
    if (otpState != null) {
      final otp = otpState.getOtp();
      if (otp.length == 4) {
        _handleOtpVerification(otp);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the complete 4-digit OTP code')),
        );
      }
    }
  }
}

class VerifyButton extends StatelessWidget {
  final VoidCallback onVerify;

  const VerifyButton({
    super.key,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onVerify,
        child: const Text('Verify'),
      ),
    );
  }
}

class ResendButton extends StatelessWidget {
  const ResendButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Did you don\'t get code?'),
        TextButton(
          onPressed: () {},
          child: const Text('Resend'),
        ),
      ],
    );
  }
}

class NumberVerificationHeader extends StatelessWidget {
  const NumberVerificationHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDefaults.padding),
        Text(
          'Entry Your 4 digit code',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDefaults.padding),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: const AspectRatio(
            aspectRatio: 1 / 1,
            child: NetworkImageWithLoader(
              AppImages.numberVerfication,
            ),
          ),
        ),
        const SizedBox(height: AppDefaults.padding * 3),
      ],
    );
  }
}

class OTPTextFields extends StatefulWidget {
  final Function(String) onOtpComplete;

  const OTPTextFields({
    super.key,
    required this.onOtpComplete,
  });

  @override
  State<OTPTextFields> createState() => _OTPTextFieldsState();
}

class _OTPTextFieldsState extends State<OTPTextFields> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  void _checkOtpComplete() {
    final otp = getOtp();
    if (otp.length == 4) {
      widget.onOtpComplete(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.otpInputDecorationTheme,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          return SizedBox(
            width: 68,
            height: 68,
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onChanged: (v) {
                if (v.length == 1 && index < 3) {
                  _focusNodes[index + 1].requestFocus();
                } else if (v.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                _checkOtpComplete();
              },
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
            ),
          );
        }),
      ),
    );
  }
}
