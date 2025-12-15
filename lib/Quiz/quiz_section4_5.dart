import '../models/quiz_models.dart';

List<QuizQuestion> buildSection4And5Questions() {
  return const [
    QuizQuestion(
      sectionTitle: 'SECTION 4 — Emotional Wellbeing',
      question: "How does your skin currently make you feel?",
      isMultiSelect: false,
      options: [
        "Confident",
        "Neutral",
        "Sometimes discouraged",
        "Overwhelmed and not sure what to do",
        "I'm here to learn more",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 4 — Emotional Wellbeing',
      question: "What is your intention for using SERUM?",
      subtitle: "Select all that resonate.",
      isMultiSelect: true,
      options: [
        "Understand my skin better",
        "Build a routine that feels gentle and realistic",
        "Improve specific concerns",
        "Track progress over time",
        "Feel more confident in my skin",
        "Take care of myself more consistently",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 5 — Your Goals',
      question: "What are your top skincare goals?",
      subtitle: "Select 1–3.",
      isMultiSelect: true,
      options: [
        "Strengthen my moisture barrier",
        "Reduce breakouts",
        "Calm redness or irritation",
        "Brighten dark spots",
        "Smooth texture",
        "Improve hydration + glow",
        "Build a stress-free routine",
        "Learn what ingredients work for me",
      ],
    ),
    QuizQuestion(
      sectionTitle: 'SECTION 5 — Your Goals',
      question: "What type of recommendation style do you prefer?",
      isMultiSelect: false,
      options: [
        "Keep it simple",
        "Balanced - not too much, not too little",
        "I love details and explanations",
        "Just tell me what works based on science",
      ],
    ),
  ];
}
