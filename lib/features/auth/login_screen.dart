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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) {
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
    return _buildResponsiveLayout(context);
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile =
        size.width < 800; // Breakpoint for Mobile/Tablet vs Desktop
    final isSmallMobile = size.width < 400;

    // --- Responsive Dimensions & Constants ---

    // 1. Section Heights
    final greenSectionHeight = size.height * 0.70;
    final yellowSectionHeight = size.height * 0.15;

    // 2. Brand Image Size & Fit
    final double brandImageWidth = isMobile ? 360 : 480;
    final double brandImageHeight = isMobile ? 196 : 250;
    final BoxFit brandImageFit = isMobile ? BoxFit.contain : BoxFit.fill;

    // 3. Form
    final double formMaxWidth = isMobile ? 340 : 450;
    // On mobile, we might want to allow scrolling if height is small,
    // but the design request focuses on fixed layout structure.
    // We'll keep the Center > SingleChildScrollView pattern for safety on short screens.

    // 4. Bottom Content (Text, Button, Lottie)
    //    Web: 740px container, 110px padding left
    //    Mobile: Full width container, reduced padding
    final double bottomContentMaxWidth = isMobile ? size.width : 740;

    // Padding for Text & Button
    // Web: 110px. Mobile: 32px (standard margin).
    final double contentLeftPadding = isMobile ? 32.0 : 110.0;

    // Gap between Text & Button
    // Web: 60px (Increased to center text in gap).
    const double textButtonGap = 60.0;

    // Lottie Position
    // Web: Offset(-80, 60).
    // Mobile: Needs to be less aggressive to fit on screen.
    // We'll adjust X offset based on available space.
    final Offset lottieOffset = isMobile
        ? const Offset(-20, 60)
        : const Offset(-80, 60);

    // Lottie Size
    // On really small mobiles, maybe scale down slightly, otherwise keep 200x280
    final double lottieWidth = isSmallMobile ? 160 : 200;
    final double lottieHeight = isSmallMobile ? 224 : 280;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          false, // Prevent layout resize on keyboard (handled manually if needed, or stick to design)
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // ---------------------------------------------------------
            // 1. TOP GREEN SECTION
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
                    // A. Brand Background Pattern
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/brand_logo_bg.png',
                          width: brandImageWidth,
                          height: brandImageHeight,
                          fit: brandImageFit,
                          opacity: const AlwaysStoppedAnimation(1.0),
                        ),
                      ),
                    ),

                    // B. Centered Form Content
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: formMaxWidth),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        // Wrap in SingleChildScrollView for safety on short screens/landscape
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                'assets/images/AdeliaHealth_white.png',
                                height: isMobile ? 80 : 90,
                                fit: BoxFit.contain,
                              ).animate().fadeIn().scale(),

                              SizedBox(height: isMobile ? 40 : 60),

                              // "Log in" Heading
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: isMobile ? 28 : 32,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight:
                                        FontWeight.w400, // Regular per design
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Form Fields
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
                                          value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    SizedBox(height: isMobile ? 40 : 48),

                                    // Login Button (White Pill)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40, // Fixed height per request
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text(
                                                'Log in',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Forgot Password
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Forgot password',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
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
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // 2. BOTTOM YELLOW SECTION
            // ---------------------------------------------------------
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: yellowSectionHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------
            // 3. BOTTOM CONTENT OVERLAY (Text, Button, Lottie)
            // ---------------------------------------------------------
            // Positioned based on user request "Text in white gap, Button in yellow"
            // We use the yellowSectionHeight as a reference anchor.
            Positioned(
              bottom: yellowSectionHeight - 70, // Anchor point
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? size.width : 800,
                  ),
                  child: SizedBox(
                    width: bottomContentMaxWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left Column: Text & Button
                        // Expanded to push Lottie to the right if needed, or shared space
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // "Or create..." Text
                              Padding(
                                padding: EdgeInsets.only(
                                  left: contentLeftPadding,
                                ),
                                child: SizedBox(
                                  width: 174,
                                  height: 56,
                                  child: RichText(
                                    textAlign: TextAlign.start,
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
                                  ),
                                ),
                              ),

                              const SizedBox(height: textButtonGap),

                              // "Join us!" Button
                              Padding(
                                padding: EdgeInsets.only(
                                  left: contentLeftPadding,
                                ),
                                child: SizedBox(
                                  width: 230, // Keep fixed width
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/signup'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC7A005),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
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
                            ],
                          ),
                        ),

                        // Spacer (Dynamic gap)
                        const Spacer(),

                        // Right Column: Lottie
                        Transform.translate(
                          offset: lottieOffset,
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
          ],
        ),
      ),
    );
  }
}
