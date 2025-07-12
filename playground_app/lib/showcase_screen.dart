import 'package:flutter/material.dart';
import 'package:playground_app/main.dart';
import 'package:webf/webf.dart';
import 'webf_screen.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Showcase'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          _buildShowcaseCard(
            context,
            title: 'MiraclePlus Demo',
            description: 'Official WebF showcase with modern UI components',
            url: 'https://miracleplus.openwebf.com/',
            color: const Color(0xFF4CAF50),
            icon: Icons.star,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'React Use Cases',
            description: 'Various React component examples and use cases',
            url: 'https://webf.openwebf.com/react-use-cases/',
            color: const Color(0xFF2196F3),
            icon: Icons.web,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vue Gallery',
            description: 'Vue.js components and Cupertino UI gallery',
            url: 'https://webf.openwebf.com/vue-gallery/',
            color: const Color(0xFF4CAF50),
            icon: Icons.view_module,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Tailwind React',
            description: 'Modern UI with Tailwind CSS and React',
            url: 'https://webf.openwebf.com/tailwind-react/',
            color: const Color(0xFF06B6D4),
            icon: Icons.design_services,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'ECharts Demo',
            description: 'Data visualization with ECharts integration',
            url: 'https://webf.openwebf.com/echarts/',
            color: const Color(0xFFFF9800),
            icon: Icons.analytics,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Hybrid Router',
            description: 'Navigation and routing examples',
            url: 'https://webf.openwebf.com/hybrid-router/',
            color: const Color(0xFF9C27B0),
            icon: Icons.route,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'BN Showcase',
            description: 'Business network components showcase',
            url: 'https://webf.openwebf.com/bn-showcase/',
            color: const Color(0xFFF44336),
            icon: Icons.business,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vite React App',
            description: 'Fast development with Vite and React',
            url: 'https://webf.openwebf.com/vite-react/',
            color: const Color(0xFF646CFF),
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vite Vue Project',
            description: 'Vite + Vue.js modern development stack',
            url: 'https://webf.openwebf.com/vite-vue/',
            color: const Color(0xFF4FC08D),
            icon: Icons.speed,
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vue Project',
            description: 'Traditional Vue.js application example',
            url: 'https://webf.openwebf.com/vue-project/',
            color: const Color(0xFF34495E),
            icon: Icons.code,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildShowcaseCard(
    BuildContext context, {
    required String title,
    required String description,
    required String url,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openWebFPage(context, title, url),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFB0B0B0),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWebFPage(BuildContext context, String title, String url) {
    final controllerName = 'showcase_${title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebFViewScreen(
          controllerName: controllerName,
          url: url,
          isDirect: true,
        ),
      ),
    );
  }
} 