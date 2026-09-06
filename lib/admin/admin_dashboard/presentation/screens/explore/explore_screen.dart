import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedField = 'All';

  final List<String> fields = [
    'All',
    'Computer Science',
    'Business',
    'Engineering',
    'Medical',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterScholarships(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final query = _searchController.text.trim().toLowerCase();

    return documents.where((document) {
      final data = document.data();

      final title = (data['title'] ?? '').toString().toLowerCase();
      final description =
          (data['description'] ?? '').toString().toLowerCase();
      final field = (data['field'] ?? '').toString();

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          description.contains(query) ||
          field.toLowerCase().contains(query);

      final matchesField =
          selectedField == 'All' || field == selectedField;

      return matchesSearch && matchesField;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Saved Scholarships',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SavedScholarshipsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search careers, scholarships...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Filter by Field',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(field),
                        selected: selectedField == field,
                        onSelected: (_) {
                          setState(() {
                            selectedField = field;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Explore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildCategory(
                    'Careers',
                    Icons.work_outline,
                  ),
                  const SizedBox(width: 8),
                  _buildCategory(
                    'Scholarships',
                    Icons.school_outlined,
                  ),
                  const SizedBox(width: 8),
                  _buildCategory(
                    'Mentors',
                    Icons.people_outline,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Scholarships',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Firestore Scholarships
              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('scholarships')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading scholarships.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No scholarships available.',
                        ),
                      );
                    }

                    final scholarships =
                        _filterScholarships(snapshot.data!.docs);

                    if (scholarships.isEmpty) {
                      return const Center(
                        child: Text(
                          'No scholarships found.',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: scholarships.length,
                      itemBuilder: (context, index) {
                        final document = scholarships[index];
                        final data = document.data();

                        return _buildScholarshipCard(
                          context,
                          document.id,
                          data,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title section selected'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, size: 28),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScholarshipCard(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final title = (data['title'] ?? 'Scholarship').toString();

    final description =
        (data['description'] ?? 'No description available.')
            .toString();

    final field = (data['field'] ?? 'Not specified').toString();

    final deadline = (data['deadline'] ?? 'Not specified').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const CircleAvatar(
          child: Icon(Icons.school),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$description\n\nField: $field\nDeadline: $deadline',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScholarshipDetailScreen(
                documentId: documentId,
                data: data,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================================================
// SCHOLARSHIP DETAIL SCREEN
// ======================================================

class ScholarshipDetailScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const ScholarshipDetailScreen({
    super.key,
    required this.documentId,
    required this.data,
  });

  @override
  State<ScholarshipDetailScreen> createState() =>
      _ScholarshipDetailScreenState();
}

class _ScholarshipDetailScreenState
    extends State<ScholarshipDetailScreen> {
  bool isSaved = false;
  bool isLoading = true;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final user = currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    final savedDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_scholarships')
        .doc(widget.documentId)
        .get();

    if (mounted) {
      setState(() {
        isSaved = savedDoc.exists;
        isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    final user = currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please login first to save scholarships.',
            ),
          ),
        );
      }
      return;
    }

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_scholarships')
        .doc(widget.documentId);

    try {
      if (isSaved) {
        await savedRef.delete();

        if (mounted) {
          setState(() {
            isSaved = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Scholarship removed from saved items.',
              ),
            ),
          );
        }
      } else {
        await savedRef.set({
          'scholarshipId': widget.documentId,
          'title': widget.data['title'] ?? 'Scholarship',
          'description': widget.data['description'] ?? '',
          'field': widget.data['field'] ?? '',
          'deadline': widget.data['deadline'] ?? '',
          'eligibility': widget.data['eligibility'] ?? '',
          'savedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            isSaved = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Scholarship saved successfully.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to save scholarship: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.data['title'] ?? 'Scholarship').toString();

    final description =
        (widget.data['description'] ??
                'No description available.')
            .toString();

    final field =
        (widget.data['field'] ?? 'Not specified').toString();

    final deadline =
        (widget.data['deadline'] ?? 'Not specified').toString();

    final eligibility =
        (widget.data['eligibility'] ?? 'Not specified')
            .toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            _buildDetailSection(
              'Description',
              description,
            ),

            _buildDetailSection(
              'Field',
              field,
            ),

            _buildDetailSection(
              'Deadline',
              deadline,
            ),

            _buildDetailSection(
              'Eligibility',
              eligibility,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _toggleSave,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  isSaved
                      ? 'Saved Scholarship'
                      : 'Save Scholarship',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SAVED SCHOLARSHIPS SCREEN
// ======================================================

class SavedScholarshipsScreen extends StatelessWidget {
  const SavedScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Scholarships'),
        ),
        body: const Center(
          child: Text(
            'Please login to view saved scholarships.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Scholarships'),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_scholarships')
            .orderBy(
              'savedAt',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading saved scholarships.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No saved scholarships yet.',
              ),
            );
          }

          final savedScholarships = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedScholarships.length,
            itemBuilder: (context, index) {
              final document = savedScholarships[index];

              final data = document.data();

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.bookmark),
                  ),
                  title: Text(
                    (data['title'] ?? 'Scholarship').toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Field: '
                    '${data['field'] ?? 'Not specified'}\n'
                    'Deadline: '
                    '${data['deadline'] ?? 'Not specified'}',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ScholarshipDetailScreen(
                          documentId: document.id,
                          data: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}