import '../models/quiz_question.dart';

List<QuizQuestion> buildSection1Questions() {
  return const [
    QuizQuestion(
      sectionTitle: 'SECTION 1 — Your Skin’s Natural State',
      question: "How would you describe your skin’s usual behavior?",
      subtitle: "This helps us personalize your routine.",
      isMultiSelect: false,
      options: [
        "Oily most of the time",
        "Dry or tight",
        "Combination (oily T-zone, dry areas)",
        "Normal / balanced",
        "It changes often",
      ],
      unsureOption: "I’m not sure",
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 1 — Your Skin’s Natural State',
      question: "How sensitive is your skin?",
      isMultiSelect: false,
      options: [
        "Very sensitive — reacts easily",
        "Mildly sensitive — sometimes reactive",
        "Rarely reacts",
      ],
      unsureOption: "I’m not sure",
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 1 — Your Skin’s Natural State',
      question: "How often does your skin break out?",
      isMultiSelect: false,
      options: [
        "Frequently",
        "Occasionally",
        "Rarely",
        "Almost never",
        "I deal more with texture than breakouts",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 1 — Your Skin’s Natural State',
      question: "What concerns do you notice most often?",
      subtitle: "Select all that apply.",
      isMultiSelect: true,
      options: [
        "Dryness or flakiness",
        "Oily shine",
        "Redness or irritation",
        "Acne or clogged pores",
        "Dark spots / uneven tone",
        "Fine lines / loss of elasticity",
        "Dullness / tired-looking skin",
        "Sensitivity",
        "None — just building a routine",
      ],
    ),
  ];
}
