import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../careers/data/models/career_model.dart';
import '../providers/career_recommendations_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class CareerRecommendationsScreen extends StatefulWidget {
  const CareerRecommendationsScreen({super.key});

  @override
  State<CareerRecommendationsScreen> createState() => _CareerRecommendationsScreenState();
}

class _CareerRecommendationsScreenState extends State<CareerRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<CareerRecommendationsProvider>().loadRecommendations(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CareerRecommendationsProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Career Recommendations')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : provider.recommendations.isEmpty
                  ? const Center(
                      child: Text(
                        'Complete your Skill Assessment first to get recommendations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.recommendations.length,
                      itemBuilder: (context, index) {
                        final item = provider.recommendations[index];
                        final career = item['career'] as CareerModel;
                        return Card(
                          color: _kSurface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(career.title, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              item['reason'] as String? ?? '',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: _kAccent,
                              child: Text(
                                '${item['matchScore']}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
