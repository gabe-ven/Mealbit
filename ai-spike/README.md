# AI Vision Feasibility Test

A standalone script that sends meal photos to Claude and prints nutrition
estimates. It is not part of the iOS app; it exists to check accuracy, speed,
and cost before AI photo logging is built.

## Setup

1. Create an API key at https://platform.claude.com (Settings → API Keys).
2. In this folder, create a file named `.env` containing:

   ```
   ANTHROPIC_API_KEY=your-key-here
   ```

   `.env` is git-ignored. Never commit the key or put it in the iOS app.
3. Install dependencies: `npm install`

## Run

Put a few meal photos (JPEG, PNG, or HEIC) in `photos/`, then:

```
npm run test-vision
npm run test-vision -- --model claude-haiku-5-5
npm run test-vision -- path/to/one-photo.jpg
```

Photos are resized to 1568 px JPEG before upload, as the app will do.
The `photos/` folder is git-ignored.
