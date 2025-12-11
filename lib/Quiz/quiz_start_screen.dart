import 'package:flutter/material.dart';
import 'package:skincare_project/Quiz/user_quiz.dart';

class QuizStartScreen extends StatelessWidget {
  const QuizStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3), // soft cream background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TITLE
                const Text(
                  "Welcome to your\nskincare journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D), // soft black
                  ),
                ),

                const SizedBox(height: 20),

                // SUBTITLE
                const Text(
                  "Let’s explore your skin, your habits,\nand what makes you feel your best.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF5A5A5A),
                  ),
                ),

                const SizedBox(height: 220), // pushes button lower like mockup

                // GOLDEN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SkinCareQuizScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCC27A), // soft gold
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Begin your journey",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
