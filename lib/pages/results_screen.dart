import 'package:flutter/material.dart';
import '../constants/brand_colors.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import '../services/products_cache.dart';
import '../services/recommendation_service.dart';
import '../services/recommendation_store.dart';
import '../services/routine_store.dart';
import '../services/user_profile_store.dart';
import '../utils/routine_builder.dart';
import '../models/user_profile.dart';
import '../models/routine_step.dart';
import '../pages/weather_page.dart';

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
                final answerText = ans.isEmpty ? "No answer" : ans.join(', ');

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

              // button 1: redo quiz (go back)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  // pop = go back to quiz screen (so user can redo it)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Redo Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // button 2: continue to weather page
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    final quizService = QuizService();
                    final profileStore = UserProfileStore.instance;
                    final recommendationStore = RecommendationStore.instance;
                    const recommendationService = RecommendationService();
                    final routineStore = RoutineStore.instance;
                    final routineBuilder = RoutineBuilder();

                    //answers to firestore
                    final Map<String, dynamic> answersToSave = answers.map(
                          (key, value) => MapEntry(key.toString(), value),
                    );

                    await quizService.saveQuizAnswers(answersToSave);

                    final profile = UserProfile.fromQuizResults(answers);
                    profileStore.setProfile(profile);

                    final products =
                    await ProductsCache.instance.getProducts(limit: 200);
                    final recommendedProducts =
                    recommendationService.filterRecommendedProducts(
                      products: products,
                      profile: profile,
                    );

                    recommendationStore.setRecommendations(recommendedProducts);

                    final wantsPrebuilt = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Choose your routine'),
                          content: const Text(
                            'Would you like a prebuilt routine with products '
                                'selected for you, or build your own with recommended '
                                'products?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Build my own'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Prebuilt routine'),
                            ),
                          ],
                        );
                      },
                    );

                    final prebuilt = wantsPrebuilt ?? false;
                    final morningSteps = routineBuilder.buildSteps(
                      type: RoutineType.morning,
                      profile: profile,
                      recommendedProducts: recommendedProducts,
                      autoSelectProducts: prebuilt,
                    );
                    final nightSteps = routineBuilder.buildSteps(
                      type: RoutineType.night,
                      profile: profile,
                      recommendedProducts: recommendedProducts,
                      autoSelectProducts: prebuilt,
                    );

                    routineStore.setMorningSteps(morningSteps);
                    routineStore.setNightSteps(nightSteps);
                    routineStore.clearMorningSelections();
                    routineStore.clearNightSelections();

                    if (prebuilt) {
                      for (final step in morningSteps) {
                        final product = step.selectedProduct;
                        if (product != null) {
                          routineStore.setMorning(
                            label: step.title,
                            productId: product.id,
                          );
                        }
                      }
                      for (final step in nightSteps) {
                        final product = step.selectedProduct;
                        if (product != null) {
                          routineStore.setNight(
                            label: step.title,
                            productId: product.id,
                          );
                        }
                      }
                    }

                    Navigator.pushReplacement(
                      context,
                      // go to weather page after quiz is confirmed
                      MaterialPageRoute(builder: (_) => const WeatherPage()),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: accentDark, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
