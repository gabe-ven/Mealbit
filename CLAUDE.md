# Mealbit — Claude Code Instructions

## Project Overview

Mealbit is a native iOS nutrition-tracking app built with Swift and SwiftUI for UC Davis ECS 191.

The app helps users track calories and macronutrients with minimal effort. Its main differentiator is simple food logging, including AI-assisted meal recognition from photos.

Read `PROJECT.md` before implementing features to understand the project's goals, scope, and user experience.

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Local Storage:** SwiftData
- **IDE:** Xcode
- **AI Integration:** Vision-capable LLM API (provider to be determined)
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
- Prioritize ease of use and fast meal logging.
- Follow Apple's Human Interface Guidelines.
- Use consistent spacing, typography, and colors.
- Keep navigation simple.
- Avoid unnecessary animations or decorative elements.
- Make calories and macronutrients easy to understand at a glance.

## Core Features

Implement features according to `PROJECT.md`.

The initial MVP includes:

1. **Dashboard:** Daily calorie and macro progress.
2. **Manual Logging:** Add meals with nutritional information.
3. **AI Photo Logging:** Estimate meal information from a picture.
4. **Meal Management:** View, edit, and delete logged meals.

Do not implement features outside the MVP unless explicitly requested.

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

## AI Integration

- Test the selected vision API before integrating it into the main app.
- AI should estimate meal names, calories, protein, carbohydrates, and fat.
- Treat AI-generated nutritional information as estimates, not facts.
- Always allow users to review and edit results before saving.
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
2. A complete core user flow
3. Simple, intuitive UI
4. Reliable local persistence
5. Maintainable code

Avoid unnecessary infrastructure, premature optimization, and features outside the agreed project scope.