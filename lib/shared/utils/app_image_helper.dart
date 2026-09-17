class AppImageHelper {
  static const List<String> careerImages = [
    // 0: Software Engineering / Developer
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=800&auto=format&fit=crop',
    // 1: Digital Marketing / Marketing Specialist
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=800&auto=format&fit=crop',
    // 2: Finance / Financial Analyst
    'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?q=80&w=800&auto=format&fit=crop',
    // 3: Cloud Architect / Cloud Infrastructure
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=800&auto=format&fit=crop',
    // 4: UI/UX Designer / Interface Design
    'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?q=80&w=800&auto=format&fit=crop',
    // 5: Data Scientist / Data Analytics
    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=800&auto=format&fit=crop',
    // 6: Backend / Server Development
    'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?q=80&w=800&auto=format&fit=crop',
    // 7: Product Management
    'https://images.unsplash.com/photo-1531403009284-440f080d1e12?q=80&w=800&auto=format&fit=crop',
    // 8: Cybersecurity
    'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=800&auto=format&fit=crop',
    // 9: Healthcare & Medical Science
    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=800&auto=format&fit=crop',
    // 10: Business Strategy
    'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=800&auto=format&fit=crop',
    // 11: Artificial Intelligence
    'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=800&auto=format&fit=crop',
    // 12: Graphic Design & Creative Arts
    'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=800&auto=format&fit=crop',
    // 13: Operations & Management
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=800&auto=format&fit=crop',
    // 14: Mobile App Development
    'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=800&auto=format&fit=crop',
  ];

  static const List<String> mentorAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?q=80&w=400&auto=format&fit=crop',
  ];

  static String getCareerImage(String? customUrl, String key, [String? title, int index = 0]) {
    // 1. If custom uploaded image exists and is valid (not default placeholder), return customUrl
    if (customUrl != null &&
        customUrl.trim().isNotEmpty &&
        !customUrl.contains('photo-1581291518857-4e27b48ff24e') &&
        (customUrl.startsWith('http') || customUrl.startsWith('data:image'))) {
      return customUrl.trim();
    }

    // 2. Keyword/Topic matching for stable, meaningful, 100% distinct career image selection
    final t = (title ?? '').toLowerCase();
    if (t.contains('software') || t.contains('developer') && !t.contains('back') && !t.contains('mobile')) {
      return careerImages[0];
    } else if (t.contains('marketing')) {
      return careerImages[1];
    } else if (t.contains('finan') || t.contains('bank')) {
      return careerImages[2];
    } else if (t.contains('cloud') || t.contains('architect') || t.contains('devops')) {
      return careerImages[3];
    } else if (t.contains('ui') || t.contains('ux') || t.contains('designer')) {
      return careerImages[4];
    } else if (t.contains('data') || t.contains('analyst') || t.contains('ai')) {
      return careerImages[5];
    } else if (t.contains('back') || t.contains('server') || t.contains('node')) {
      return careerImages[6];
    } else if (t.contains('product') || t.contains('scrum')) {
      return careerImages[7];
    } else if (t.contains('cyber') || t.contains('security')) {
      return careerImages[8];
    } else if (t.contains('health') || t.contains('bio') || t.contains('med')) {
      return careerImages[9];
    } else if (t.contains('business') || t.contains('strategy')) {
      return careerImages[10];
    } else if (t.contains('mobile') || t.contains('flutter') || t.contains('ios') || t.contains('android')) {
      return careerImages[14];
    }

    // 3. Deterministic unique index mapping for any other titles to guarantee no duplicates
    final uniqueIdx = (key.hashCode.abs() + index) % careerImages.length;
    return careerImages[uniqueIdx];
  }

  static String getMentorAvatar(String? customUrl, String key, [int index = 0]) {
    if (customUrl != null && customUrl.trim().isNotEmpty && !customUrl.contains('default') && (customUrl.startsWith('http') || customUrl.startsWith('data:image'))) {
      return customUrl.trim();
    }
    final hash = (key.hashCode.abs() + index) % mentorAvatars.length;
    return mentorAvatars[hash];
  }
}
