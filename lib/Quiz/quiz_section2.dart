import 'quiz_models.dart';

List<QuizQuestion> buildSection2Questions() {
  return const [
    QuizQuestion(
      sectionTitle: 'SECTION 2 — Your Daily Habits',
      question: "How consistent are your skincare habits right now?",
      isMultiSelect: false,
      options: [
        "Very consistent",
        "Somewhat consistent",
        "I’m just getting started",
        "I struggle with consistency",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 2 — Your Daily Habits',
      question: "What does your current routine look like?",
      subtitle: "Select all that apply.",
      isMultiSelect: true,
      options: [
        "Cleanser",
        "Moisturizer",
        "Sunscreen",
        "Toner",
        "Serum",
        "Exfoliant (AHA/BHA)",
        "Retinol",
        "Prescription skincare",
        "I don’t have a routine yet",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 2 — Your Daily Habits',
      question: "How many products do you prefer using daily?",
      isMultiSelect: false,
      options: [
        "2–3 steps (simple)",
        "4–5 steps (balanced)",
        "6+ steps (maximalist)",
        "Whatever is recommended for my skin",
      ],
    ),
  ];
}
