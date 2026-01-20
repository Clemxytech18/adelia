import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../shared/underlined_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Sign up with email and password
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'display_name': _firstNameController.text,
        },
      );

      if (mounted) {
        if (authResponse.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please login.')),
          );
          context.go('/login');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occured')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topSectionHeight = size.height * 0.15; // Small green header

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // 1. Top Green Section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topSectionHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary, // #72AE8C
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                alignment: Alignment.center,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'I already have an account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Middle "Or create your account" Text
            Positioned(
              left: 32,
              top: topSectionHeight + 20,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    height: 1.2,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(text: 'Or '),
                    TextSpan(
                      text: 'create',
                      style: TextStyle(
                        color: Color(0xFF449CCE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '\nyour '),
                    TextSpan(
                      text: 'account',
                      style: TextStyle(
                        color: Color(0xFF449CCE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '!'),
                  ],
                ),
              ).animate().fadeIn().slideX(),
            ),

            // 3. Bottom Yellow Section (Main Form)
            Positioned(
              top: topSectionHeight + 110, // Increased to uncover text
              bottom: 0, // Extend to bottom (keyboard will shrink this area)
              left: 0,
              right: 0,
              // height: removed fixed height to allows shrinking
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.secondary, // #F5CC5C
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  // Allow scrolling for form
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ), // Spacing for Lottie clearance
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            UnderlinedTextField(
                              controller: _emailController,
                              label: 'Email',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            UnderlinedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              isPassword: true,
                              validator: (value) =>
                                  value == null || value.length < 6
                                  ? 'Min 6 chars'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            UnderlinedTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            UnderlinedTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 48),

                            // Join us! Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFC7A005,
                                  ), // Dark Gold
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Join us!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Lottie Illustration (Overlapping)
            Positioned(
              right: -10, // Move further right to clear text
              top: isKeyboardOpen
                  ? 40
                  : topSectionHeight + 10, // Move up when keyboard open
              height: 140,
              child: Lottie.asset(
                'assets/lottie/joinus_nobackground.json',
                fit: BoxFit.contain,
              ),
            ),

            // 5. Bottom Brand Background (Hide on keyboard open)
            if (!isKeyboardOpen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/brand_logo_bottom_bg.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
