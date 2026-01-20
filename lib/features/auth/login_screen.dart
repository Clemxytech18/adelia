import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../shared/underlined_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileFormKey = GlobalKey<FormState>();
  final _webFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    // Validate whichever form is active?
    // Easier: Check both or check based on context?
    // Since we don't know easily which one is built in this method without context size check again,
    // let's just use the logic:
    // If we are in the build method, we switch. here we are in a callback.
    // We can check if `_mobileFormKey.currentState` is mounted/valid, or `_webFormKey.currentState`.

    if (_mobileFormKey.currentState != null) {
      if (!_mobileFormKey.currentState!.validate()) return;
    } else if (_webFormKey.currentState != null) {
      if (!_webFormKey.currentState!.validate()) return;
    } else {
      // Should not happen
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        context.go('/');
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWebLayout(context, constraints);
        } else {
          return _buildMobileLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final greenSectionHeight = size.height * 0.7;
    final footerHeight = size.height * 0.15;

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
              height: greenSectionHeight,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // #72AE8C
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: Stack(
                  children: [
                    // Brand Background Pattern (Original Size)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/brand_logo_bg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Centered Content
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Logo
                            Image.asset(
                              'assets/images/AdeliaHealth_white.png',
                              height: 100,
                              fit: BoxFit.contain,
                            ).animate().fadeIn().scale(),

                            const SizedBox(height: 60),

                            // "Log in" Text
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                  children: [
                                    TextSpan(text: 'Log '),
                                    TextSpan(
                                      text: 'in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Form
                            Form(
                              key: _webFormKey,
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
                                        value == null || value.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 40),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Log in',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot password',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Bottom Yellow Footer Section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: footerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go('/signup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7A005),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Join us!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Middle Section Content (Or create... and Lottie)
            Positioned(
              bottom: footerHeight - 60, // Adjust overlap
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  height: 300, // Increase container height to fit Lottie
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Text on Left
                      Positioned(
                        left: 50,
                        bottom: 80,
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 28,
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
                        ),
                      ),

                      // Lottie on Right
                      Positioned(
                        right: 50,
                        bottom: 0,
                        height: 300,
                        width: 220,
                        child: Lottie.asset(
                          'assets/lottie/joinus_nobackground.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final greenSectionHeight = size.height * 0.75;
    final footerHeight = size.height * 0.15;
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
              height: greenSectionHeight,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // #72AE8C
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Stack(
                  children: [
                    // Brand Background Pattern (Original Size)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/brand_logo_bg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Main Content Overlay
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Logo
                            Image.asset(
                              'assets/images/AdeliaHealth_white.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ).animate().fadeIn().scale(),

                            const SizedBox(height: 60),

                            // "Log in" Text
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                  children: [
                                    TextSpan(text: 'Log '),
                                    TextSpan(
                                      text: 'in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Form
                            Form(
                              key:
                                  _mobileFormKey, // Note: Sharing GlobalKey between layouts might cause issues if hot-switching, but acceptable here
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
                                        value == null || value.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 40),

                                  // Login Button (White Pill)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                                color: AppColors.primary,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Log in',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  TextButton(
                                    onPressed: () {
                                      // Forgot password logic
                                    },
                                    child: const Text(
                                      'Forgot password',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Bottom Yellow Footer Section (Hide on keyboard open)
            if (!isKeyboardOpen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: footerHeight,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.secondary, // #F5CC5C
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFC7A005,
                        ), // Darker shade
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Join us!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. "Or create your account!" Text (Hide on keyboard open)
            if (!isKeyboardOpen)
              Positioned(
                left: 32,
                bottom: footerHeight + 20,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 20,
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
                ).animate().fadeIn(delay: 600.ms).slideX(),
              ),

            // 4. Lottie Illustration (Hide on keyboard open)
            if (!isKeyboardOpen)
              Positioned(
                right: -20,
                bottom: 40,
                height: 300,
                width: 220,
                child: Lottie.asset(
                  'assets/lottie/joinus_nobackground.json',
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
