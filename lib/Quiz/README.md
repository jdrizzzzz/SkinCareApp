# SERUM Skincare Quiz — Directory Overview

This folder contains all files used to run the SERUM multi-step skincare quiz.  
The quiz is divided into smaller modules so each section can be updated easily without touching the entire flow.

---

## `user_quiz.dart`

Main controller for the quiz.

**Responsibilities:**
- Combines all quiz sections into one list of questions
- Handles step-by-step navigation (forward/back + progress bar)
- Stores user answers (single-choice and multi-select)
- Renders the special “Location or City Input” step
- Validates answers before moving to the next question
- Sends all answers to `ResultsScreen` at the end

If you want to change the quiz order or add a new section, this is the file you edit.

---

## `quiz_models.dart`

Shared models, UI widgets, and brand styling.

**Includes:**
- Color palette for SERUM quiz screens
- `QuizQuestion` model  
  (defines question text, options, whether it’s multi-select, etc.)
- `OptionCard`  
  (the rounded answer cards used across the quiz)
- `ResultsScreen`  
  (shows the final summary of all questions and answers)

When updating design, colors, or core reusable widgets, make the changes here.

---

## `quiz_section1.dart` — Skin’s Natural State

Contains Section 1 questions about the user’s baseline skin behavior.

**Covers:**
- Skin type / usual behavior
- Sensitivity levels
- Breakout frequency
- Main skin concerns (multi-select)

This file is where you adjust or rewrite any biology-focused questions.

---

## `quiz_section2.dart` — Daily Habits

Covers routine consistency and the user’s existing skincare habits.

**Includes:**
- How consistent their routine is
- What products they currently use (multi-select)
- How many steps they prefer in a routine

Edit this file when you need to update habit-related questions.

---

## `quiz_section3.dart` — Lifestyle & Environment

Focuses on external factors that affect the skin.

**Includes:**
- Climate step (special handling in `user_quiz.dart`)
- Stress levels
- Sleep duration
- Sun exposure frequency

The climate question is marked with `isLocationStep: true`, which triggers the custom UI for location or manual city entry.

---

## `quiz_section4_5.dart` — Emotional Wellbeing & Goals

Covers the user's emotional relationship with their skin and their personal goals.

**Includes:**
- How their skin makes them feel
- Intentions for using SERUM (multi-select)
- Top skincare goals (multi-select)
- Preferred recommendation style

This is the file to update when refining tone, intentions, or goal-setting.

---