import '../models/quiz_question.dart';

List<QuizQuestion> buildSection3Questions() {
  return const [
    // Special climate/location step
    QuizQuestion(
      sectionTitle: 'SECTION 3 — Lifestyle & Environment',
      question: "Would you like SERUM to detect your local climate automatically?",
      isMultiSelect: false,
      options: [], // handled specially in main screen
      isLocationStep: true,
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 3 — Lifestyle & Environment',
      question: "How would you describe your stress levels lately?",
      isMultiSelect: false,
      options: [
        "High",
        "Moderate",
        "Low",
        "It varies",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 3 — Lifestyle & Environment',
      question: "How much sleep do you usually get?",
      isMultiSelect: false,
      options: [
        "Less than 6 hours",
        "6–7 hours",
        "7–8 hours",
        "More than 8 hours",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 3 — Lifestyle & Environment',
      question: "How often are you outdoors in the sun?",
      isMultiSelect: false,
      options: [
        "Daily",
        "A few times a week",
        "Rarely",
        "Almost never",
      ],
    ),
  ];
}
