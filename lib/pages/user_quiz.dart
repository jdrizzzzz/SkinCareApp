import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/quiz_models.dart';
import '../Quiz/quiz_section1.dart';
import '../Quiz/quiz_section2.dart';
import '../Quiz/quiz_section3.dart';
import '../Quiz/quiz_section4_5.dart';

class SkinCareQuizScreen extends StatefulWidget {
  const SkinCareQuizScreen({Key? key}) : super(key: key);

  @override
  State<SkinCareQuizScreen> createState() => _SkinCareQuizScreenState();
}

class _SkinCareQuizScreenState extends State<SkinCareQuizScreen> {
  int _currentIndex = 0;

  final Map<int, String> _singleAnswers = {};
  final Map<int, Set<String>> _multiAnswers = {};

  bool _isRequestingLocation = false;

  late final List<QuizQuestion> _questions = [
    ...buildSection1Questions(),
    ...buildSection2Questions(),
    ...buildSection3Questions(),
    ...buildSection4And5Questions(),
  ];

  bool _isAnswered(int index) {
    final q = _questions[index];

    if (q.isLocationStep) {
      final value = _singleAnswers[index];
      return value != null && value.startsWith("Location:");
    }

    if (!q.isMultiSelect) {
      return _singleAnswers[index] != null;
    } else {
      final values = _multiAnswers[index];
      return values != null && values.isNotEmpty;
    }
  }

  void _onNext() {
    if (!_isAnswered(_currentIndex)) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _submitQuiz() {
    final Map<int, List<String>> allAnswers = {};
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.isMultiSelect) {
        allAnswers[i] = _multiAnswers[i]?.toList() ?? [];
      } else {
        final value = _singleAnswers[i];
        allAnswers[i] = value == null ? [] : [value];
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          questions: _questions,
          answers: allAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final totalSteps = _questions.length;
    final stepNumber = _currentIndex + 1;
    final progress = stepNumber / totalSteps;

    final bool isMulti = q.isMultiSelect;
    final String? selectedSingle = _singleAnswers[_currentIndex];
    final Set<String> selectedMulti =
        _multiAnswers[_currentIndex] ?? <String>{};

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: _onBack,
        ),
        title: const Text(
          'SERUM',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $stepNumber of $totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    q.sectionTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (q.subtitle != null && !q.isLocationStep) ...[
                    const SizedBox(height: 8),
                    Text(
                      q.subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: q.isLocationStep
                  ? _buildLocationStep(_currentIndex)
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ...q.options.map(
                          (option) {
                        final bool isSelected = isMulti
                            ? selectedMulti.contains(option)
                            : selectedSingle == option;
                        return OptionCard(
                          text: option,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isMulti) {
                                final set =
                                    _multiAnswers[_currentIndex] ??
                                        <String>{};
                                if (set.contains(option)) {
                                  set.remove(option);
                                } else {
                                  set.add(option);
                                }
                                _multiAnswers[_currentIndex] = set;
                              } else {
                                _singleAnswers[_currentIndex] = option;
                              }
                            });
                          },
                        );
                      },
                    ),
                    if (!isMulti && q.unsureOption != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _singleAnswers[_currentIndex] =
                              q.unsureOption!;
                            });
                          },
                          child: const Text(
                            "I’m not sure",
                            style: TextStyle(
                              fontSize: 14,
                              color: accentDark,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isAnswered(_currentIndex) ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex == _questions.length - 1
                          ? 'See My Skin Profile'
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(int index) {
    final hasAnswer = _singleAnswers[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your skin is shaped by your environment — humidity, temperature, UV levels, air quality, and seasonal changes all affect how your barrier behaves.\n\n"
                "SERUM uses your location only to understand your climate so we can support your skin with clarity, not pressure.\n\n"
                "To continue, please allow SERUM to detect your local climate automatically.",
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
              _isRequestingLocation ? null : () => _handleAllowLocation(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isRequestingLocation
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
                  : const Text(
                "Allow Location",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (hasAnswer != null && hasAnswer.startsWith("Location:"))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Saved: $hasAnswer",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAllowLocation(int index) async {
    setState(() {
      _isRequestingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are turned off. Please enable them to continue the quiz.',
            ),
          ),
        );
        setState(() {
          _isRequestingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isRequestingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'SERUM needs location permission to continue. Please allow access in Settings.',
            ),
          ),
        );

        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isRequestingLocation = false;
        _singleAnswers[index] = "Location: "
            "${position.latitude.toStringAsFixed(2)}, "
            "${position.longitude.toStringAsFixed(2)}";
      });
    } catch (_) {
      setState(() {
        _isRequestingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We couldn’t get your location. Please check your settings and try again.',
          ),
        ),
      );
    }
  }
}
