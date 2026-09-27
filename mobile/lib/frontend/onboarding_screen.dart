import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101D), // Dark navy background
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            // Subtle grid pattern simulation or subtle dark radial glow
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.0,
              colors: [
                Color(0xFF16233B),
                Color(0xFF0B101D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Header: Skip Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E2D4A), width: 1.5),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/home');
                        },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF8A99AD),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Illustration Placeholder / Database Icon Graphic
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial background glow behind illustration
                      Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1D3254),
                        ),
                      ),
                      // Replace Icon with Image.asset('assets/images/database_illustration.png') if available
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121D30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF213555)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.storage_rounded,
                              size: 50,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF183258),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACADEMIC PROJECT',
                    style: TextStyle(
                      color: Color(0xFF4FA8F6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Main Title
                const Text(
                  'Firearms Catalog',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'A structured mobile database management app for cataloging and managing firearm model records. Built for an Integrative Technologies CRUD project.',
                    style: TextStyle(
                      color: Color(0xFF8E9BAE),
                      fontSize: 14,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // Feature List Cards
                _buildFeatureCard(
                  icon: Icons.check_circle_outline_rounded,
                  text: 'Structured reference database',
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  icon: Icons.check_circle_outline_rounded,
                  text: 'Full CRUD operations',
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  icon: Icons.check_circle_outline_rounded,
                  text: 'REST Countries API integration',
                ),

                const Spacer(flex: 2),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildDot(),
                    const SizedBox(width: 6),
                    _buildDot(),
                    const SizedBox(width: 6),
                    _buildDot(),
                  ],
                ),

                const SizedBox(height: 20),

                // "Next" Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/home');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3B82F6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
  ),
  child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Next',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      SizedBox(width: 6),
      Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 20,
      ),
    ],
  ),
),
                ),

                const SizedBox(height: 16),

                // Bottom Footer Counter Text
                const Text(
                  '1 of 4 · Academic reference project',
                  style: TextStyle(
                    color: Color(0xFF53627A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Feature Item Cards
  Widget _buildFeatureCard({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF10192A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D4A), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF22C55E), // Vibrant green checkmark
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Inactive Page Indicator Dots
  Widget _buildDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2D4A),
        shape: BoxShape.circle,
      ),
    );
  }
}