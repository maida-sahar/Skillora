import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../admin/admin_dashboard/presentation/screens/explore/explore_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skillora Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    await authProvider.signOut();
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              const Color(0xFF6C5CE7).withAlpha(51),
                          backgroundImage:
                              (user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                          child: (user?.avatarUrl == null ||
                                  user!.avatarUrl!.isEmpty)
                              ? Text(
                                  (user?.displayName.isNotEmpty == true)
                                      ? user!.displayName[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C5CE7),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Student User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Role: ${(user?.role ?? 'student').toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'Edit Profile >',
                                    style: TextStyle(
                                      color: Color(0xFF6C5CE7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteNames.skillAssessment);
                  },
                  icon: const Icon(Icons.smart_toy),
                  label: const Text('Start AI Skill Assessment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Skillora Career Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.explore,
                        color: Color(0xFF6C5CE7),
                      ),
                      title: Text('Career Recommendations'),
                      subtitle: Text(
                        'Discover personalized paths based on your skills',
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.school,
                        color: Color(0xFF6C5CE7),
                      ),
                      title: const Text('Scholarships Directory'),
                      subtitle: const Text(
                        'Explore funding and eligibility criteria',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExploreScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(
                        Icons.assignment,
                        color: Color(0xFF6C5CE7),
                      ),
                      title: Text('Applications & Deadlines'),
                      subtitle: Text(
                        'Track submitted applications and deadlines',
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}