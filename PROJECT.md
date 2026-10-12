# Mealbit — Project Overview

## Overview

Mealbit is a simple iOS nutrition-tracking app inspired by MyFitnessPal. It helps users understand what they're eating and track their daily calories and macronutrients without a complicated interface.

The main focus is making food logging as quick and easy as possible.

## Problem

People want to reach nutrition goals such as eating enough protein, managing calories, or improving their eating habits. However, tracking food manually can feel tedious and time-consuming.

Mealbit aims to reduce the effort required to log meals and understand daily nutritional progress.

## Target Users

People who want to track their nutrition without spending much time logging food, especially students, gym-goers, and people with calorie or protein goals.

## Core User Flow

1. Open Mealbit and see today's nutritional progress.
2. Tap a button to add a meal.
3. Choose to enter food manually or take a picture.
4. Review the meal's calories and macronutrients.
5. Edit any incorrect values and save the meal.
6. See the updated daily summary.

## MVP Features

### 1. Daily Dashboard
- Daily calorie goal and current intake
- Protein, carbs, and fats
- Progress indicators
- List of today's meals

### 2. Manual Food Logging
- Enter a meal name
- Enter calories, protein, carbohydrates, and fats
- Choose breakfast, lunch, dinner, or snack
- Save the meal

### 3. AI Photo Logging
- Take or select a food photo
- Use a vision-capable AI model to identify food
- Estimate calories and macronutrients
- Allow users to review and edit estimates
- Save the confirmed meal

### 4. Meal Management
- View logged meals
- Edit existing meals
- Delete meals
- Automatically update daily totals

## Design Principles

- Minimal, clean interface
- Logging a meal should take as few steps as possible
- Daily progress should be immediately visible
- No unnecessary screens or distracting features
- AI estimates should always be editable

## Technical Stack

- Platform: iOS
- Language: Swift
- UI: SwiftUI
- Data persistence: SwiftData
- AI: Vision-capable LLM API, subject to early feasibility testing
- Development: Xcode

## Out of Scope

- User accounts
- Social features
- Recipes
- Barcode scanning
- Exercise tracking
- Coaching
- Complex analytics
- Cloud synchronization

## Success Criteria

A first-time user should be able to:

1. Understand what Mealbit does from the home screen.
2. Log a meal without instructions.
3. Review and correct nutritional information.
4. Understand how the meal affects their daily goal.
5. Close and reopen the app without losing saved meals.

## Future Improvements

- Personalized nutrition goals
- Historical nutrition trends
- More reliable food recognition
- Barcode scanning
- Food database integration
