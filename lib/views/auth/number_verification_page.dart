import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  UserRole _testRole = UserRole.customer; // For testing when no signup data
  String? _verificationId; // Firebase verification ID
  bool _isLoading = false;
  bool _useFirebaseOTP = true; // Toggle between Firebase OTP and mock OTP
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get signup data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    print('=== DEBUG ROUTE ARGS ===');
    print('Arguments received: $args');
    print('Arguments type: ${args.runtimeType}');
    if (args is Map<String, dynamic>) {
      _signupData = args;
      print('Signup data set: $_signupData');
      
      // Send OTP via Firebase if phone number is provided
      if (_useFirebaseOTP && _signupData != null) {
        _sendFirebaseOTP();
      }
    } else {
      print('Arguments are not Map<String, dynamic>');
    }
    print('=== END DEBUG ===');
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
                      // Show role selector if no signup data (for testing)
                      if (_signupData == null) ...[
                        const Text('Select Role (Testing Mode):'),
                        const SizedBox(height: 8),
                        DropdownButton<UserRole>(
                          value: _testRole,
                          isExpanded: true,
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _testRole = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppDefaults.padding),
                      ],
                      // Show loading indicator
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(AppDefaults.padding),
                          child: CircularProgressIndicator(),
                        ),
                      
                      // Show OTP mode indicator
                      if (!_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDefaults.padding),
                          child: Text(
                            _useFirebaseOTP && _verificationId != null
                                ? '📱 Enter 6-digit OTP sent to your phone'
                                : '🧪 Test Mode: Enter any 6 digits',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      OTPTextFields(
                        key: _otpFieldsKey,
                        onOtpComplete: (otp) => _handleOtpVerification(otp),
                        digitCount: 6, // Changed to 6 digits for Firebase
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      ResendButton(
                        onResend: _useFirebaseOTP ? _sendFirebaseOTP : null,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      VerifyButton(
                        onVerify: () => _handleVerifyButton(),
                        isLoading: _isLoading,
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

  // Send OTP via Firebase
  Future<void> _sendFirebaseOTP() async {
    final phoneNumber = _signupData?['phoneNumber'] as String? ?? '';
    
    if (phoneNumber.isEmpty) {
      print('⚠️ No phone number provided');
      return;
    }
    
    // Ensure phone number is in international format
    String formattedPhone = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      // Assume India (+91) if no country code
      formattedPhone = '+91$phoneNumber';
    }
    
    print('📱 Sending OTP to: $formattedPhone');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          print('✅ Auto-verification completed');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          setState(() {
            _isLoading = false;
            _useFirebaseOTP = false; // Fall back to mock OTP
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('SMS verification failed. Using test mode.\n${e.message}'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP sent! Verification ID: $verificationId');
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ OTP sent to your phone!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout');
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('❌ Error sending OTP: $e');
      setState(() {
        _isLoading = false;
        _useFirebaseOTP = false; // Fall back to mock OTP
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e\nUsing test mode.')),
        );
      }
    }
  }
  
  // Handle OTP verification
  Future<void> _handleOtpVerification(String otp) async {
    if (otp.length != 6) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Use Firebase OTP if verification ID exists
    if (_useFirebaseOTP && _verificationId != null) {
      await _verifyFirebaseOTP(otp);
    } else {
      // Fall back to mock OTP
      await _verifyMockOTP(otp);
    }
  }
  
  // Verify Firebase OTP
  Future<void> _verifyFirebaseOTP(String otp) async {
    if (_verificationId == null) {
      print('❌ No verification ID');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    try {
      print('🔐 Verifying OTP: $otp');
      
      // Create credential with verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _signInWithCredential(credential);
    } catch (e) {
      print('❌ OTP verification failed: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Invalid OTP code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Verify mock OTP (for testing)
  Future<void> _verifyMockOTP(String otp) async {
    print('🧪 Using mock OTP verification');
    
    // Get role from signup data
    final UserRole role;
    if (_signupData != null) {
      final roleString = _signupData!['role'] as String? ?? 'customer';
      role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.customer,
      );
    } else {
      role = _testRole;
    }
    
    // Save user to local storage
    await LocalAuthService.saveLoginState(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _signupData?['name'] as String? ?? 'User',
      email: _signupData?['email'] as String? ?? 'user@example.com',
      phoneNumber: _signupData?['phoneNumber'] as String? ?? '1234567890',
      role: role,
      businessName: _signupData?['businessName'] as String?,
      businessAddress: _signupData?['businessAddress'] as String?,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    // Show success dialog
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
  }
  
  // Sign in with Firebase credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      print('🔐 Signing in with Firebase credential');
      
      // Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('✅ Firebase sign-in successful: ${userCredential.user?.uid}');
      
      // Get role from signup data
      final roleString = _signupData?['role'] as String? ?? 'customer';
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.customer,
      );
      
      // Save user to local storage
      await LocalAuthService.saveLoginState(
        userId: userCredential.user?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _signupData?['name'] as String? ?? 'User',
        email: _signupData?['email'] as String? ?? 'user@example.com',
        phoneNumber: _signupData?['phoneNumber'] as String? ?? '',
        role: role,
        businessName: _signupData?['businessName'] as String?,
        businessAddress: _signupData?['businessAddress'] as String?,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success dialog
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
      print('❌ Sign in failed: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }


  void _handleVerifyButton() {
    // Collect OTP from text fields
    final otpState = _otpFieldsKey.currentState;
    if (otpState != null) {
      final otp = otpState.getOtp();
      _handleOtpVerification(otp);
    }
  }
}

class VerifyButton extends StatelessWidget {
  final VoidCallback onVerify;
  final bool isLoading;

  const VerifyButton({
    super.key,
    required this.onVerify,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onVerify,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Verify'),
      ),
    );
  }
}

class ResendButton extends StatelessWidget {
  final VoidCallback? onResend;
  
  const ResendButton({
    super.key,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Didn\'t get code?'),
        TextButton(
          onPressed: onResend,
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
          'Enter Your 6 Digit Code',
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
  final int digitCount;

  const OTPTextFields({
    super.key,
    required this.onOtpComplete,
    this.digitCount = 6,
  });

  @override
  State<OTPTextFields> createState() => _OTPTextFieldsState();
}

class _OTPTextFieldsState extends State<OTPTextFields> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(widget.digitCount, (_) => FocusNode());
  }

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
    if (otp.length == widget.digitCount) {
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
        children: List.generate(widget.digitCount, (index) {
          return SizedBox(
            width: 50,
            height: 60,
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onChanged: (v) {
                if (v.length == 1 && index < widget.digitCount - 1) {
                  _focusNodes[index + 1].requestFocus();
                } else if (v.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                _checkOtpComplete();
              },
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
