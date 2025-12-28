import 'package:flutter/material.dart';

class LandingPageScreen extends StatefulWidget {
  const LandingPageScreen({super.key});

  @override
  State<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends State<LandingPageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<bool> _dragComplete = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    final features = [
      {
        'title': 'Manage Aptitude Tests',
        'desc': 'Create, edit, and analyze aptitude assessments for students.',
        'icon': Icons.book_outlined,
      },
      {
        'title': 'Course & Stream Control',
        'desc': 'Add, update, and map courses to student profiles.',
        'icon': Icons.school_outlined,
      },
      {
        'title': 'College Management',
        'desc': 'Maintain college listings, eligibility rules, and intake details.',
        'icon': Icons.business_outlined,
      },
      {
        'title': 'Scholarship Oversight',
        'desc': 'Verify, approve, and publish scholarship opportunities.',
        'icon': Icons.emoji_events_outlined,
      },
    ];

    final steps = [
      'Configure Aptitude Tests',
      'Manage Courses & Streams',
      'Verify Colleges & Data',
      'Publish Scholarships',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF0FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            _buildHeroSection(context, isMobile),

            // FEATURES SECTION
            _buildFeaturesSection(features, isMobile),

            // STEPS SECTION
            _buildStepsSection(steps, isMobile),

            // CTA SECTION
            _buildCTASection(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 40 : 60),
      child: Column(
        children: [
          // Badge
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF444EE7), Color(0xFF6B74FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.explore, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Admin Control Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Heading
          SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Text(
                  'Manage Student Pathways',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 42,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF444EE7),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'With Full Control',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6B74FF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Monitor student progress, manage academic data, and ensure accurate guidance at scale.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF1E40AF),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          FadeTransition(
            opacity: _fadeAnimation,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/dashboard');
                  },
                  icon: const Icon(Icons.dashboard, size: 20),
                  label: const Text('Admin Dashboard'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: const Color(0xFF444EE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signin');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    foregroundColor: const Color(0xFF444EE7),
                    side: const BorderSide(color: Color(0xFF444EE7), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Hero Image
          FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC7CBFF), width: 4),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 80, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(List<Map<String, dynamic>> features, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 40 : 60),
      color: const Color(0xFFF5F6FF),
      child: Column(
        children: [
          // Section Title
          const Text(
            'Admin Capabilities',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF444EE7),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interact with each module to unlock administrative controls.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 40),

          // Feature Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 800
                      ? 2
                      : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: features.length,
                itemBuilder: (context, i) {
                  return _buildFeatureCard(
                    features[i]['title'] as String,
                    features[i]['desc'] as String,
                    features[i]['icon'] as IconData,
                    i,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String desc, IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _dragComplete[index] = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFC7CBFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF444EE7)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E40AF),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _dragComplete[index]
                    ? Colors.green.withOpacity(0.3)
                    : const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _dragComplete[index] ? '✓ Enabled' : 'Tap to Enable',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _dragComplete[index]
                      ? Colors.green[800]
                      : const Color(0xFF444EE7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(List<String> steps, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 40 : 60),
      child: Column(
        children: [
          const Text(
            'How Admin Works',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF444EE7),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: List.generate(steps.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepCard(i + 1, steps[i]),
                  if (i < steps.length - 1)
                    Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF444EE7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int number, String text) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC7CBFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF444EE7), Color(0xFF6B74FF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF444EE7).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444EE7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 40 : 80),
      color: const Color(0xFFF5F6FF),
      child: Column(
        children: [
          const Text(
            'Ready to manage the platform?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF444EE7),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Access powerful tools to control students, courses, colleges, and scholarships efficiently.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: const Color(0xFF444EE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 12,
            ),
            child: const Text(
              'Open Admin Panel 🚀',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}