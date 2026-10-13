// Feasibility test: send food photos to Claude and print nutrition estimates.
// Usage: npm run test-vision -- [--model <model-id>] [photo ...]
// With no photos given, every image in ./photos is used.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod";

const DEFAULT_MODEL = "claude-opus-5-5";
const MAX_IMAGE_DIMENSION = 1568;
const IMAGE_EXTENSIONS = new Set([".jpg", ".jpeg", ".png", ".heic", ".webp"]);

const MealEstimate = z.object({
  is_food: z.boolean().describe("False if the photo does not clearly show food or drink."),
  meal_name: z.string().describe("Short, human-friendly meal name, e.g. 'Chicken Burrito Bowl'."),
  calories: z.number().int().describe("Estimated total kcal for everything visible."),
  protein_g: z.number(),
  carbs_g: z.number(),
  fat_g: z.number(),
  confidence: z.enum(["low", "medium", "high"]),
  notes: z.string().describe("One sentence on portion-size assumptions or what was unclear."),
});

const SYSTEM_PROMPT = `You estimate nutrition for a food-logging app from a single meal photo.
Identify the food and estimate total calories and macronutrients for the entire portion visible.
When portion size is unclear, assume a typical single serving and say so in notes.
If the photo does not clearly show food, set is_food to false, use an empty meal_name, and set all numbers to 0.
The user will review and edit your estimate before saving, so give your best single estimate rather than a range.`;

function parseArgs(argv) {
  let model = DEFAULT_MODEL;
  const photos = [];
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--model") model = argv[++i];
    else photos.push(argv[i]);
  }
  if (photos.length === 0 && fs.existsSync("photos")) {
    for (const name of fs.readdirSync("photos").sort()) {
      if (IMAGE_EXTENSIONS.has(path.extname(name).toLowerCase())) photos.push(path.join("photos", name));
    }
  }
  return { model, photos };
}

/** Resize and convert to JPEG with macOS `sips`, similar to what the app will upload. */
function prepareImage(photoPath) {
  const outPath = path.join(os.tmpdir(), `mealbit-${process.pid}-${path.basename(photoPath)}.jpg`);
  execFileSync("sips", ["-s", "format", "jpeg", "-Z", String(MAX_IMAGE_DIMENSION), photoPath, "--out", outPath], {
    stdio: "ignore",
  });
  const data = fs.readFileSync(outPath);
  fs.rmSync(outPath);
  return data;
}

async function estimate(client, model, photoPath) {
  const image = prepareImage(photoPath);
  const started = Date.now();
  const response = await client.messages.parse({
    model,
    max_tokens: 1024,
    system: SYSTEM_PROMPT,
    messages: [
      {
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: "image/jpeg", data: image.toString("base64") } },
          { type: "text", text: "Estimate the nutrition for this meal." },
        ],
      },
    ],
    output_config: { format: zodOutputFormat(MealEstimate) },
  });
  return {
    result: response.parsed_output,
    stopReason: response.stop_reason,
    seconds: (Date.now() - started) / 1000,
    usage: response.usage,
    uploadKB: Math.round(image.length / 1024),
  };
}

async function main() {
  const { model, photos } = parseArgs(process.argv.slice(2));
  if (photos.length === 0) {
    console.log("No photos found. Put images in ai-spike/photos/ or pass paths as arguments.");
    process.exit(1);
  }
  if (!process.env.ANTHROPIC_API_KEY) {
    console.log("ANTHROPIC_API_KEY is not set. Add it to ai-spike/.env (see README.md).");
    process.exit(1);
  }

  const client = new Anthropic();
  console.log(`Model: ${model}\n`);

  for (const photo of photos) {
    console.log(`== ${path.basename(photo)}`);
    try {
      const { result, stopReason, seconds, usage, uploadKB } = await estimate(client, model, photo);
      if (!result) {
        console.log(`   Could not parse a response (stop reason: ${stopReason}).`);
      } else if (!result.is_food) {
        console.log(`   Not recognized as food. ${result.notes}`);
      } else {
        console.log(`   ${result.meal_name}: ${result.calories} kcal`);
        console.log(`   P ${result.protein_g}g · C ${result.carbs_g}g · F ${result.fat_g}g  (confidence: ${result.confidence})`);
        console.log(`   ${result.notes}`);
      }
      console.log(`   ${seconds.toFixed(1)}s · ${uploadKB} KB upload · ${usage.input_tokens} in / ${usage.output_tokens} out tokens`);
    } catch (error) {
      if (error instanceof Anthropic.APIError) {
        console.log(`   API error ${error.status}: ${error.message}`);
      } else {
        console.log(`   Failed: ${error.message}`);
      }
    }
    console.log();
  }
}

main();
