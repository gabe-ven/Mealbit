# Mealbit — Claude Code Instructions

## Project Overview

Mealbit is a native iOS nutrition decision assistant built with Swift and SwiftUI for UC Davis ECS 191.

The app helps students and gym-goers decide what to eat *before* eating it. The user photographs a potential meal, reviews an AI estimate, and sees how it would affect their remaining calorie and protein goals. They can adjust portions and then log or discard the meal. The interactive meal preview is the main differentiator; manual logging and the daily dashboard are supporting features.

Read `PROJECT.md` before implementing features to understand the project's goals, scope, and user experience.

For UX and flow decisions, use the course lecture `docs/ECS 191_ Product engineering.pdf` as a reference. Its main ideas: reduce "time to magic," make the one core loop obvious, keep everything else spartan, and avoid features that need a tutorial.

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Local Storage:** SwiftData
- **IDE:** Xcode
- **AI Integration:** Claude (Anthropic API) vision model, called through a small backend proxy
- **Target Platform:** iOS

Use native Apple frameworks whenever possible.

Do not introduce React Native, Flutter, or web-based UI frameworks.

## Development Principles

### 1. Keep Things Simple
- Prefer straightforward, readable code over complex abstractions.
- Avoid overengineering or unnecessary design patterns.
- Don't introduce third-party dependencies unless necessary.
- Build only what is required for the current feature.
- Prefer simple solutions appropriate for a student project.

### 2. Work Incrementally
- Implement one feature or phase at a time.
- Do not build future features without being asked.
- Break larger tasks into smaller, manageable steps.
- Keep existing functionality working when adding features.
- Ask before making significant architectural changes.

### 3. Code Quality
- Follow standard Swift naming conventions.
- Keep SwiftUI views reasonably small and readable.
- Extract reusable components when they genuinely reduce duplication.
- Separate UI code from data persistence and API interactions.
- Use descriptive variable and function names.
- Avoid unnecessary comments that simply repeat what the code does.
- Handle errors and loading states appropriately.

### 4. UI/UX Guidelines
- Use a clean, minimal design.
- Prioritize a fast path from photo to meal preview.
- Follow Apple's Human Interface Guidelines.
- Use consistent spacing, typography, and colors.
- Keep navigation simple.
- Avoid unnecessary animations or decorative elements.
- Make calories and macronutrients easy to understand at a glance.

## Core Features

Implement features according to `PROJECT.md`.

The MVP includes:

1. **Daily Goals:** User-set calorie and protein goals.
2. **Meal Preview (main feature):** Show a meal's impact on remaining goals before logging, with a short plain-language explanation of how it fits, and portion and ingredient adjustments.
3. **AI Photo Estimation:** Estimate a meal and its components from a picture.
4. **Manual Entry (supporting):** Enter nutrition values, then open the same preview.
5. **Dashboard and Meal Management (supporting):** Daily progress; view, edit, and delete logged meals.

Do not implement features outside the MVP unless explicitly requested. Side-by-side meal comparison is a stretch goal; do not build it until the meal-preview workflow is complete and tested.

Generate the goal-fit explanation on the device from the preview numbers using simple rules, not with an AI call.

## Data Management

- Use SwiftData for local persistence.
- Meals should persist when the app closes and reopens.
- Each meal should store:
  - Unique identifier
  - Meal name
  - Meal category (breakfast, lunch, dinner, snack)
  - Calories
  - Protein
  - Carbohydrates
  - Fat
  - Date and time
- Calculate daily totals from saved meals rather than maintaining duplicate totals.
- Store daily goals as simple on-device settings (`@AppStorage`), not in SwiftData.
- A meal preview is temporary, in-memory state. Save a `Meal` only when the user taps Log; discarding a preview must leave no saved data.

## AI Integration

- Test the selected vision API before integrating it into the main app.
- AI should estimate the meal name and its main components, each with an estimated quantity, calories, protein, carbohydrates, and fat.
- Make one AI request per photo. Recalculate portion and ingredient adjustments on the device by scaling; never call the AI again for them.
- Treat AI-generated nutritional information as estimates, not facts, and label nutrition values as approximate in the UI.
- Always allow users to review and edit results before logging.
- Handle unclear images, network failures, and invalid API responses.
- Never hardcode API secrets in the iOS application or commit them to Git.
- Prefer a small backend proxy for requests requiring a secret API key.
- Do not add AI functionality until the basic manual logging system works.

## Testing and Validation

After implementing a feature:

1. Check for Swift compiler errors.
2. Build and test the app when Xcode tooling is available.
3. Verify that existing features still work.
4. Test important edge cases.
5. Explain what was implemented and how to test it.

Never claim a build or test passed unless it was actually run.

## Git Guidelines

- Make small, focused changes.
- Use descriptive commit messages.
- Do not commit API keys, credentials, or generated build artifacts.
- Do not commit or push changes unless explicitly requested.
- Do not rewrite Git history or force-push without permission.

## Communication Guidelines

When working on Mealbit:

- Explain your approach briefly before implementing major changes.
- Prefer implementing the simplest working solution.
- Explain important technical decisions in plain language.
- Mention any tradeoffs or limitations.
- When finishing a task, summarize what changed, what was tested, and what remains.
- If there are multiple reasonable approaches, recommend the simplest one.

## Important Constraints

This is a course project, not a production application.

Prioritize:
1. A working native iOS application
2. A complete, testable meal-preview workflow over additional features
3. Simple, intuitive UI
4. Reliable local persistence
5. Maintainable code

Avoid unnecessary infrastructure, premature optimization, and features outside the agreed project scope.