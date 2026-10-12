# Mealbit — Project Overview

## Overview

Mealbit is a native iOS **nutrition decision assistant** for students and gym-goers. Instead of only recording what someone already ate, Mealbit helps them decide what to eat *before* eating it.

The user photographs a potential meal, reviews an AI estimate of its calories and macronutrients, and immediately sees how that meal would affect what's left of their daily calorie and protein goals. They can adjust portions or ingredient quantities, watch the impact update, and then choose to log the meal, change it, or discard it.

Manual logging and a simple daily dashboard remain as supporting features. The interactive meal preview is the main differentiator.

## Problem

People with calorie or protein goals usually make food decisions in the moment: in a dining hall, at a restaurant, or while cooking. Traditional trackers like MyFitnessPal only help *after* the decision, by recording what was eaten. By then it is too late to adjust.

The questions users actually have before eating are:

- "If I eat this, how much of my calorie budget is left?"
- "Does this get me closer to my protein goal?"
- "What if I only eat half the rice, or add another chicken breast?"

Answering these today means searching a food database, guessing portion sizes, and doing mental math. Mealbit answers them in a few seconds from a photo.

## Target Users

- **College students** eating at dining halls, campus restaurants, or cooking simple meals, who want to stay within a calorie budget.
- **Gym-goers** who want to hit a daily protein target without overshooting calories.

Both groups make several food decisions a day, are comfortable using a phone camera, and want a quick answer rather than a detailed food diary.

## Core User Flow

1. Set a daily calorie goal and protein goal (once, editable later).
2. Take or choose a photo of a meal they are considering.
3. AI identifies the food and estimates calories, protein, carbs, and fat, broken down by the main components of the meal.
4. Review and correct the estimate.
5. See a **meal preview**: how the meal would change the remaining calories and protein for today. Nothing is logged yet.
6. Adjust the overall portion or individual ingredient quantities and watch the totals and impact update instantly.
7. Decide: **Log** the meal, keep adjusting it, or **Discard** the preview.

Manual entry follows the same flow from step 4. The user enters values instead of taking a photo and still gets the preview.

## MVP Features

### 1. Daily Goals
- Set a daily calorie goal and protein goal
- Edit goals at any time
- Stored on the device; no accounts

### 2. Meal Preview (main feature)
- Shows the meal's calories, protein, carbs, and fat, clearly labeled as approximate
- Shows before/after impact on today's remaining calories and protein
- A short, plain-language explanation of how the meal fits the goals, for example: "Uses about 40% of your remaining calories and covers most of the protein you still need." or "Would put you about 200 kcal over today's goal."
- Clearly indicates when a meal would exceed the calorie goal
- Overall portion adjustment (for example, ½×, 1×, 1½×, 2×)
- Per-ingredient quantity adjustment when the meal has components
- Totals recalculate instantly on the device
- Log or discard; nothing is saved until the user logs it

### 3. AI Photo Estimation
- Take a photo or choose one from the library
- A vision-capable AI model identifies the food and its main components
- Estimates calories and macronutrients per component
- Indicates confidence and states its portion assumptions
- Handles unclear photos, non-food photos, and network errors
- All estimates are labeled as approximate and are editable before logging

### 4. Manual Entry (supporting)
- Enter meal name, category, calories, protein, carbs, and fat
- Opens the same meal preview before logging

### 5. Daily Dashboard and Meal Management (supporting)
- Today's calorie and protein progress toward the user's goals
- Carbs and fat totals
- List of today's logged meals by category
- Edit or delete logged meals; totals update automatically

## Design Principles

- The meal preview should answer "should I eat this?" at a glance
- A complete, testable meal-preview workflow takes priority over adding features
- Getting from photo to preview should take as few steps as possible
- Nutrition values are always labeled as approximate and always editable
- Adjusting a portion should feel instant, with no waiting on the network
- Minimal, clean interface following Apple's Human Interface Guidelines
- No unnecessary screens or distracting features

## Technical Stack

- Platform: iOS
- Language: Swift
- UI: SwiftUI
- Data persistence: SwiftData (logged meals); on-device settings for goals
- AI: Claude (Anthropic API) vision model, called through a small backend proxy so the API key never ships in the app
- Development: Xcode

## Out of Scope

- User accounts or cloud sync
- Social features
- Recipes or meal planning
- Barcode scanning
- Food database search
- Exercise tracking
- Coaching or AI chat
- Meal recommendations ("what should I eat instead")
- Historical trends or analytics
- Goals beyond calories and protein (for example, carb or fat targets)

## Success Criteria

In a test with five target users, each user should be able to:

1. Set their goals without help.
2. Go from a meal photo to a meal preview in under 30 seconds.
3. Explain in their own words, from the preview, how the meal affects their remaining calories and protein.
4. Correct an inaccurate AI estimate.
5. Adjust a portion and understand how the impact changed.
6. Log or discard the meal and see the dashboard reflect their choice.
7. Close and reopen the app without losing goals or logged meals.

## Stretch Goal (not in the initial MVP)

**Side-by-side meal comparison:** preview two candidate meals and compare their impact on the remaining goals. Consider this only after the full meal-preview workflow is complete and tested with users. It should reuse the existing preview calculations.

## Future Improvements

- Suggestions for portion changes that fit the remaining goals
- Carb and fat goals
- Historical trends
- Barcode scanning and food database lookup
- Improved recognition for specific dining halls or restaurants
