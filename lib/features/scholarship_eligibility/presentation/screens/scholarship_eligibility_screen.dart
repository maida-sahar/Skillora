import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../scholarships/data/models/scholarship_model.dart';
import '../providers/eligibility_provider.dart';

const _kBackground = Color(0xFF121212);
const _kSurface = Color(0xFF1E1E1E);
const _kAccent = Color(0xFF6366F1);

class ScholarshipEligibilityScreen extends StatefulWidget {
  const ScholarshipEligibilityScreen({super.key});

  @override
  State<ScholarshipEligibilityScreen> createState() => _ScholarshipEligibilityScreenState();
}

class _ScholarshipEligibilityScreenState extends State<ScholarshipEligibilityScreen> {
  final _fieldController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EligibilityProvider>().loadScholarships();
    });
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EligibilityProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(backgroundColor: _kBackground, elevation: 0, title: const Text('Scholarship Eligibility')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _fieldController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Your Field of Study',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: _kSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => provider.setProfile(field: v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _countryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Your Country',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: _kSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => provider.setProfile(country: v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.errorMessage != null
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
                      : provider.scholarships.isEmpty
                      ? const Center(
                          child: Text('No open scholarships right now.', style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.scholarships.length,
                          itemBuilder: (context, index) {
                            final s = provider.scholarships[index];
                            return _ScholarshipCard(scholarship: s);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final ScholarshipModel scholarship;
  const _ScholarshipCard({required this.scholarship});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EligibilityProvider>();
    final score = provider.scoreFor(scholarship);
    final scoreValue = score['score'] as int;
    final color = scoreValue >= 70
        ? Colors.greenAccent
        : scoreValue >= 40
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Card(
      color: _kSurface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(scholarship.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(scholarship.organization, style: const TextStyle(color: Colors.white54)),
        trailing: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text('$scoreValue%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusRow(label: 'Field matches your input', ok: score['fieldMatches'] as bool),
                _StatusRow(label: 'Country matches your input', ok: score['countryMatches'] as bool),
                const SizedBox(height: 8),
                const Text('Tick the criteria you meet:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ...scholarship.eligibilityCriteria.asMap().entries.map((e) {
                  final checked = provider.isCriterionChecked(scholarship.id, e.key);
                  return CheckboxListTile(
                    value: checked,
                    activeColor: _kAccent,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(e.value, style: const TextStyle(color: Colors.white70)),
                    onChanged: (_) => provider.toggleCriterion(scholarship.id, e.key),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ok;
  const _StatusRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.greenAccent : Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
