import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/course_model.dart';
import '../providers/courses_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class CoursesResourcesScreen extends StatefulWidget {
  const CoursesResourcesScreen({super.key});

  @override
  State<CoursesResourcesScreen> createState() => _CoursesResourcesScreenState();
}

class _CoursesResourcesScreenState extends State<CoursesResourcesScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userId != null) context.read<CoursesProvider>().load(_userId!);
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Courses & Resources')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Search courses',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: _kSurface,
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: provider.search,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Recommended for my skill gaps', style: TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Switch(
                      value: provider.recommendedOnly,
                      activeThumbColor: _kAccent,
                      onChanged: _userId == null ? null : (_) => provider.toggleRecommendedOnly(_userId!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Error: ${provider.errorMessage}',
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : provider.courses.isEmpty
                        ? const Center(child: Text('No courses found.', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.courses.length,
                            itemBuilder: (context, index) {
                              final course = provider.courses[index];
                              return _CourseCard(course: course, onTap: () => _open(course.url));
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _kSurface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(course.title, style: const TextStyle(color: Colors.white)),
        subtitle: Text('${course.provider} · ${course.type}', style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.open_in_new, color: _kAccent, size: 18),
      ),
    );
  }
}
