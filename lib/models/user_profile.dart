//Converts quiz answers to userprofile object
class UserProfile {
  final String? skinType;
  final Set<String> conditions;
  final Set<String> allergies;
  final Set<String> goals;
  final Set<String> preferences;

  const UserProfile({
    this.skinType,
    required this.conditions,
    required this.allergies,
    required this.goals,
    required this.preferences,
  });

  factory UserProfile.fromQuizResults(Map<int, List<String>> answers) {
    final flattened = answers.values.expand((v) => v).toList();
    return UserProfile.fromAnswerStrings(flattened);
  }

  factory UserProfile.fromSavedAnswers(Map<String, dynamic> answers) {
    final flattened = <String>[];
    for (final entry in answers.entries) {
      final value = entry.value;
      if (value is List) {
        flattened.addAll(value.whereType<String>());
      } else if (value is String) {
        flattened.add(value);
      }
    }
    return UserProfile.fromAnswerStrings(flattened);
  }

  factory UserProfile.fromAnswerStrings(List<String> answers) {
    final normalized = answers.map((a) => a.trim().toLowerCase()).toList();

    String? pickSkinType() {
      const skinTypes = ['oily', 'dry', 'combination', 'normal', 'sensitive'];
      for (final type in skinTypes) {
        if (normalized.any((a) => a.contains(type))) {
          return type;
        }
      }
      return null;
    }

    Set<String> pickMatches(List<String> candidates) {
      return candidates
          .where((candidate) => normalized.any((a) => a.contains(candidate)))
          .toSet();
    }

    return UserProfile(
      skinType: pickSkinType(),
      conditions: pickMatches(['eczema', 'acne', 'rosacea', 'psoriasis']),
      allergies: pickMatches([
        'fragrance',
        'perfume',
        'parfum',
        'alcohol',
        'niacinamide',
      ]),
      goals: pickMatches([
        'hydration',
        'brightening',
        'anti-aging',
        'anti aging',
        'pigmentation',
        'texture',
      ]),
      preferences: pickMatches([
        'minimal',
        'gentle',
        'realistic',
        'stress-free',
        'stress free',
      ]),
    );
  }
}