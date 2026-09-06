import 'package:cloud_firestore/cloud_firestore.dart';

class RoadmapStep {
  final String text;
  final bool completed;

  const RoadmapStep({required this.text, this.completed = false});

  factory RoadmapStep.fromMap(Map<String, dynamic> map) {
    return RoadmapStep(
      text: map['text'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {'text': text, 'completed': completed};

  RoadmapStep copyWith({bool? completed}) =>
      RoadmapStep(text: text, completed: completed ?? this.completed);
}

/// A saved Learning Roadmap for one (student, target career) pair.
/// Firestore doc id is "{userId}_{careerId}" — re-saving from Skill Gap
/// Analysis replaces the previous roadmap for that career.
class RoadmapModel {
  final String id;
  final String userId;
  final String careerId;
  final String careerTitle;
  final List<String> missingSkills;
  final List<RoadmapStep> steps;
  final DateTime createdAt;

  const RoadmapModel({
    required this.id,
    required this.userId,
    required this.careerId,
    required this.careerTitle,
    this.missingSkills = const [],
    this.steps = const [],
    required this.createdAt,
  });

  int get completedCount => steps.where((s) => s.completed).length;

  double get progress => steps.isEmpty ? 0 : completedCount / steps.length;

  factory RoadmapModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final stepsList = (data['steps'] as List? ?? [])
        .map((e) => RoadmapStep.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return RoadmapModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      careerId: data['careerId'] as String? ?? '',
      careerTitle: data['careerTitle'] as String? ?? '',
      missingSkills: List<String>.from(data['missingSkills'] ?? []),
      steps: stepsList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'careerId': careerId,
      'careerTitle': careerTitle,
      'missingSkills': missingSkills,
      'steps': steps.map((s) => s.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
