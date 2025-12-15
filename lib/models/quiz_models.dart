import 'package:flutter/material.dart';

/// Brand colors (shared)
const Color bgColor = Color(0xFFF5EBE0); // Light beige
const Color accentColor = Color(0xFFF2C94C); // Warm yellow
const Color accentDark = Color(0xFFE0B34B);
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF333333);

/// Quiz question model
class QuizQuestion {
  final String sectionTitle;
  final String question;
  final String? subtitle;
  final bool isMultiSelect;
  final List<String> options;
  final String? unsureOption;
  final bool isLocationStep; // special climate/location step

  const QuizQuestion({
    required this.sectionTitle,
    required this.question,
    this.subtitle,
    required this.isMultiSelect,
    required this.options,
    this.unsureOption,
    this.isLocationStep = false,
  });
}

/// Card widget used for each option tile
class OptionCard extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.text,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.spa,
                size: 22,
                color: accentDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Results screen that shows all questions + answers
class ResultsScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, List<String>> answers;

  const ResultsScreen({
    Key? key,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        title: const Text(
          'Your Skin Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✨ Your Personalized Skin Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Based on your answers, here’s a snapshot of your skin, habits, and goals.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(questions.length, (index) {
                final q = questions[index];
                final ans = answers[index] ?? [];
                final answerText =
                ans.isEmpty ? "No answer" : ans.join(', ');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5BDAF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        answerText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5BDAF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accentDark, width: 1.5),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: accentDark,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Next up: your gentle, realistic SERUM routine.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "We’ll use this profile to suggest steps, ingredients, and habits that fit your life — not perfectionism.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
