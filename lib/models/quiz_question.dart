//Defines QuizQuestion
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
