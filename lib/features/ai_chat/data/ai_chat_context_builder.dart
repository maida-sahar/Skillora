import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/models/user_model.dart';
import '../../careers/data/models/career_model.dart';
import '../../courses_resources/data/models/course_model.dart';
import '../../jobs_internships/data/models/job_model.dart';
import '../../scholarships/data/models/scholarship_model.dart';
import '../../skills/data/repositories/skills_repository_impl.dart';
import '../../skills/domain/repositories/skills_repository.dart';

/// Builds the "who is this student + what does the app offer" briefing that
/// is sent to Gemini once, at the start of a chat, so its answers are
/// personalised and grounded in the app's real Firestore data.
///
/// Every collection is loaded independently: if one read fails (rules,
/// offline, empty collection) the chat still works with the rest.
class AiChatContextBuilder {
  final FirebaseFirestore _firestore;
  final SkillsRepository _skills;

  AiChatContextBuilder({FirebaseFirestore? firestore, SkillsRepository? skills})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _skills = skills ?? SkillsRepositoryImpl();

  Future<String> build(String userId) async {
    final profileF = _safe<Map<String, dynamic>>(() => _profile(userId), {});
    final careersF = _safe<List<Map<String, dynamic>>>(_careers, const []);
    final scholarshipsF = _safe<List<Map<String, dynamic>>>(_scholarships, const []);
    final jobsF = _safe<List<Map<String, dynamic>>>(_jobs, const []);
    final coursesF = _safe<List<Map<String, dynamic>>>(_courses, const []);

    final profile = await profileF;
    final appData = {
      'careers': await careersF,
      'scholarships': await scholarshipsF,
      'jobs': await jobsF,
      'courses': await coursesF,
    };

    final today = DateTime.now().toIso8601String().substring(0, 10);

    return '''
You are "Skillora AI", a friendly career advisor inside the Skillora app for Pakistani students.

RULES
- Reply in the same language and script the student writes in (English, Roman Urdu or Urdu). If they write Roman Urdu, answer in Roman Urdu.
- Personalise every answer using the STUDENT PROFILE. If the profile is empty or thin, still help with sensible general advice and suggest completing the Skill Assessment (Profile > Skills & interests) for better results.
- When recommending careers, scholarships, jobs/internships or courses, pick from APP DATA below and use the exact titles. Give one short line on why each fits this student. If nothing in APP DATA fits, say so honestly and give general guidance instead.
- Never invent scholarships, jobs, courses, deadlines, amounts or links. Only state deadlines that appear in APP DATA. Today's date is $today; do not recommend anything whose deadline has passed.
- Keep answers short and practical: about 150 words unless the student asks for more. Use short bullet points, no long introductions.
- For scholarship eligibility, give your best assessment but remind the student to confirm on the official page.

STUDENT PROFILE (JSON):
${jsonEncode(profile)}

APP DATA (JSON):
${jsonEncode(appData)}
''';
  }

  Future<T> _safe<T>(Future<T> Function() run, T fallback) async {
    try {
      return await run();
    } catch (e) {
      debugPrint('AI chat context load failed: $e');
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _profile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final user = doc.exists ? UserModel.fromFirestore(doc) : null;

    List<Map<String, String>> assessed = const [];
    try {
      final skills = await _skills.getUserSkillsOnce(userId);
      assessed = skills.map((s) => {'skill': s.skillName, 'level': s.level.name}).toList();
    } catch (e) {
      debugPrint('AI chat: could not load assessed skills: $e');
    }

    return {
      'name': user?.displayName ?? '',
      'education': user?.educationField ?? '',
      'profileSkills': user?.skillsList ?? const <String>[],
      'assessedSkills': assessed,
      'interests': user?.interestsList ?? const <String>[],
      'careerGoals': user?.careerGoalsList ?? const <String>[],
    };
  }

  Future<List<Map<String, dynamic>>> _careers() async {
    final snap = await _firestore.collection('careers').limit(40).get();
    return snap.docs.map(CareerModel.fromFirestore).map((c) => {
          'title': c.title,
          'category': c.category,
          'requiredSkills': c.requiredSkills,
          'education': c.education,
          'level': c.careerLevel,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _scholarships() async {
    final snap = await _firestore.collection('scholarships').limit(40).get();
    final now = DateTime.now();
    final all = snap.docs.map(ScholarshipModel.fromFirestore).toList();
    final upcoming = all.where((s) => s.deadline.isAfter(now)).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return upcoming.take(15).map((s) => {
          'title': s.title,
          'organization': s.organization,
          'field': s.field,
          'country': s.country,
          'amount': s.amount,
          'deadline': s.deadline.toIso8601String().substring(0, 10),
          'eligibility': s.eligibilityCriteria,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _jobs() async {
    final snap = await _firestore.collection('jobs').limit(40).get();
    final now = DateTime.now();
    final open = snap.docs
        .map(JobModel.fromFirestore)
        .where((j) => j.status.toLowerCase() == 'open' && j.deadline.isAfter(now))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return open.take(15).map((j) => {
          'title': j.title,
          'company': j.company,
          'location': j.location,
          'type': j.type,
          'requiredSkills': j.requiredSkills,
          'deadline': j.deadline.toIso8601String().substring(0, 10),
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _courses() async {
    final snap = await _firestore.collection('courses').limit(40).get();
    return snap.docs.take(20).map(CourseModel.fromFirestore).map((c) => {
          'title': c.title,
          'provider': c.provider,
          'type': c.type,
          'category': c.category,
          'skillTags': c.skillTags,
          'url': c.url,
        }).toList();
  }
}
