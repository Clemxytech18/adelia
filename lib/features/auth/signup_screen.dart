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
    return _buildResponsiveLayout(context);
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final isSmallMobile = size.width < 400;

    // --- Responsive Dimensions for Signup (Inverted Layout) ---

    // 1. Section Heights
    // Green Header: Small (holds links)
    final greenSectionHeight = size.height * 0.18;
    // Yellow Body: Large (holds form)
    // We want a gap in between.
    // Gap: ~15-20%
    // Yellow Height: Remainder
    final yellowSectionHeight = size.height * 0.65;

    // 3. Form Width
    final double formMaxWidth = isMobile ? 340 : 450;

    // 4. Middle Content Variables (to match Login)
    final double bottomContentMaxWidth = isMobile ? size.width : 740;
    final double contentLeftPadding = isMobile ? 32.0 : 110.0;

    // Lottie Dimensions (Matched with Login)
    final double lottieWidth = isSmallMobile ? 160 : 200;
    final double lottieHeight = isSmallMobile ? 224 : 280;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // ---------------------------------------------------------
            // 1. TOP GREEN SECTION (Header)
            // ---------------------------------------------------------
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: greenSectionHeight,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Brand Pattern Removed

                    // Header Content
                    SafeArea(
                      bottom: false,
                      child: Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'I already have an account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // 2. BOTTOM YELLOW SECTION (Form Body)
            // ---------------------------------------------------------
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: yellowSectionHeight,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Brand Pattern (Bottom)
                    // Sizes: 360x196 (Mobile), 480x250 (Web)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/brand_logo_bottom_bg.png',
                        width: isMobile ? 360 : 480,
                        height: isMobile ? 196 : 220,
                        fit: BoxFit.fill,
                        opacity: const AlwaysStoppedAnimation(1.0),
                      ),
                    ),

                    // Form Content
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: formMaxWidth),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          // Top padding: 60 to clear Lottie overlap
                          // Bottom padding: Brand Image Height (250) + 20 to avoid overlap
                          padding: EdgeInsets.only(
                            top: 60,
                            bottom: (isMobile ? 196 : 220) + 20,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                UnderlinedTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                UnderlinedTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                UnderlinedTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                UnderlinedTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  isPassword: true,
                                  validator: (value) =>
                                      value == null || value.length < 6
                                      ? 'Min 6 chars'
                                      : null,
                                ),
                                const SizedBox(height: 40),

                                // "Join us!" Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC7A005),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets
                                          .zero, // Remove default padding
                                      alignment:
                                          Alignment.center, // Ensure centering
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
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
                                        : const Center(
                                            child: Text(
                                              'Join us!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // 3. MIDDLE OVERLAY (Text in White Gap + Lottie Overlap)
            // ---------------------------------------------------------
            // We anchor this Row relative to the visual "Cut" (Yellow Top).
            // Positioned at bottom: yellowSectionHeight puts the bottom on the cut.
            // We want the text ABOVE the cut (in gap) and Lottie hanging BELOW the cut.
            Positioned(
              bottom:
                  yellowSectionHeight -
                  20, // Sit slightly into the yellow section (20px) to allow Text padding to push up
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? size.width : 800,
                  ),
                  child: SizedBox(
                    width: bottomContentMaxWidth, // Use consistent width
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: contentLeftPadding,
                      ), // Align Left like Login
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // LEFT: Text
                          // Padding bottom pushes it up into the white gap
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: RichText(
                                  textAlign: TextAlign.start,
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
                            ),
                          ),

                          const Spacer(),

                          // RIGHT: Lottie
                          // Translated down to overlap yellow section
                          // It's in a Row with CrossAxis.end, so it sits on bottom line.
                          // We Translate Y positive to push it down.
                          Transform.translate(
                            offset: const Offset(-20, 80), // Push down 80px
                            child: SizedBox(
                              height: lottieHeight,
                              width: lottieWidth,
                              child: Lottie.asset(
                                'assets/lottie/joinus_nobackground.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
