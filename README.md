# Mealbit

Mealbit is a native iOS app that helps you decide what to eat **before** you eat it.
Snap a photo of a meal you're considering, and Mealbit estimates its calories and
protein, then shows how it would fit into what's left of your daily goals. Adjust
the portion or items, then add it to today, or discard it.

Built with Swift and SwiftUI for UC Davis ECS 191.

## Requirements

- A Mac with **Xcode 27** or later
- An iPhone or iOS Simulator running **iOS 18** or later
- An internet connection for photo estimates (manual logging works offline)

## Build and run

### In the simulator

1. Clone the repository and open the project:
   ```
   git clone https://github.com/gabe-ven/Mealbit.git
   cd Mealbit
   open Mealbit/Mealbit.xcodeproj
   ```
2. At the top of Xcode, choose an iPhone simulator running iOS 18 or later (for
   example, iPhone 17 Pro).
3. Press **⌘R** to build and run.

The simulator has no camera, so use **Choose Photo** to pick a meal photo from
its library. To add your own test photos, drag images onto the simulator window.

### On an iPhone

1. Connect your iPhone to your Mac with a cable, unlock it, and tap **Trust**.
2. On the iPhone, turn on **Settings → Privacy & Security → Developer Mode**.
   The phone restarts; confirm with **Turn On**.
3. In Xcode, select the **Mealbit** target, open **Signing & Capabilities**, and
   choose your own **Team** (a free Apple ID works). If Xcode reports that the
   bundle identifier is taken, change `com.gabrielvenezia.Mealbit` to something
   unique, such as `com.yourname.Mealbit`.
4. Choose your iPhone at the top of Xcode and press **⌘R**.
5. If iOS says **Untrusted Developer**, go to **Settings → General → VPN & Device
   Management**, trust your developer profile, and run again.

### Photo estimates (backend proxy)

Photo estimates are made by Claude (Anthropic's AI) through a small Cloudflare
Worker in [`proxy/`](proxy/), so the API key never ships in the app. The app
already points at a deployed proxy in
`Mealbit/Mealbit/Services/MealEstimator.swift`, so **no setup is needed to try
it**. To run your own proxy with your own key, follow
[`proxy/README.md`](proxy/README.md) and update the URL in `MealEstimator.swift`.

## Using Mealbit

### 1. Set your daily goals

On first launch, tap **Get Started** and set your daily **calories** and
**protein** with the − and + buttons, then tap **Start Checking Meals**. Tap
**Skip and use defaults** to start with 2,000 kcal and 150 g of protein.

You can change your goals anytime with the **target** button in the top right
of Home. Changes apply right away.

### 2. Check a meal before you eat it (the main feature)

1. On Home, tap **Check a Meal**.
2. Tap **Use Camera** to photograph the meal, or **Choose Photo** to pick one.
3. Bit takes a look for a few seconds, then shows the **Meal Result**:
   - The meal's name, what's in it, and its estimated calories and protein
   - **Bit's take** on how it fits, such as "Fits with 210 cal to spare" or
     "Puts you about 320 cal over", and how much of your remaining protein it covers
   - **Your day if you add this meal**: your calorie and protein totals after this
     meal. The dark blue part is what you've already eaten; the light blue part is
     this meal; amber shows anything over your goal.
4. Tap **Add to Today** to log it, or go back to discard it. Nothing is saved
   until you tap Add to Today.

If the photo isn't food or the estimate fails, Mealbit says so and lets you try
another photo, try again, or enter the meal manually.

### 3. Adjust the estimate

On the Meal Result, tap **Edit** to:

- Rename the meal
- Change the overall **portion** (½×, 1×, 1½×, 2×)
- Use **−** and **+** on any item to change its amount, or remove it
- Tap an item to fix its amount, unit, calories, protein, carbs, or fat

Every number on the result updates instantly. Adjustments are calculated on
your phone; the photo is only sent once.

### 4. Log a meal manually

On Home, tap **Log Manually**, enter a name, calories, and protein (and
optionally carbs and fat), then tap **See How It Fits**. You get the same Meal
Result screen before adding it.

### 5. Track today

Home shows:

- **Bit**, whose mood follows your day: hungry early on, happy as you eat, and
  energized as you near your calorie goal
- Calorie and protein **rings** showing what you've eaten against your goals
- **Today's Meals**, newest first. Tap a meal to edit it or **Remove from today**.

Meals are saved on your device and stay there when you close the app. Home
starts fresh each day.

## Good to know

- **Estimates are approximate.** Nutrition from a photo is an estimate, not an
  exact measurement. Check and adjust the items before adding a meal.
- **Privacy.** Meals and goals are stored only on your device. When you check a
  meal, the photo is sent to the Mealbit proxy and on to Claude to estimate it,
  and isn't stored by Mealbit.
- **Best results** come from clear, well-lit photos of the whole plate.

## Project structure

```
Mealbit/Mealbit/
  MealbitApp.swift        App entry point
  NutritionGoals.swift    Goal keys, defaults, and allowed ranges
  Models/                 Meal (SwiftData), MealDraft, GoalFit, number parsing
  Services/               MealEstimator: sends a photo to the proxy
  Views/                  Screens, the Bit mascot, theme, and icons
proxy/                    Cloudflare Worker that calls Claude
ai-spike/                 Standalone script used to test the vision API
docs/                     Course reference material
```

## Tech

Swift, SwiftUI, and SwiftData on iOS; Claude's vision model behind a Cloudflare
Worker. Icons are SF Symbols, plus a flexed-arm icon adapted from
[Material Design Icons](https://pictogrammers.com/library/mdi/) (Apache 2.0).
