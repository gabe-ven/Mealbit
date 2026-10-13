// Mealbit proxy: keeps the Claude API key off the phone.
// POST /estimate with {"image": "<base64 JPEG>"} returns a meal estimate.

const MAX_IMAGE_BASE64_LENGTH = 2_000_000; // about 1.5 MB of JPEG

const SYSTEM_PROMPT = `You estimate nutrition for a meal-planning app from a single meal photo.
Identify the meal and break it into its main components (at most 6), such as "Grilled chicken breast" or "White rice".
For each component give an estimated quantity with a common unit (oz, cup, tbsp, slice, piece, etc.) and the calories, protein, carbs, and fat for that quantity.
Include cooking oils, sauces, or dressings as their own component when they are likely present.
When portion size is unclear, assume a typical single serving and say so in notes.
If the photo does not clearly show food or drink, set is_food to false, use an empty meal_name and no components.
The user will review and adjust your estimate, so give your best single estimate rather than a range.`;

const ESTIMATE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: ["is_food", "meal_name", "components", "confidence", "notes"],
  properties: {
    is_food: { type: "boolean", description: "False if the photo does not clearly show food or drink." },
    meal_name: { type: "string", description: "Short, human-friendly meal name, e.g. 'Chicken Burrito Bowl'." },
    components: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["name", "quantity", "unit", "calories", "protein_g", "carbs_g", "fat_g"],
        properties: {
          name: { type: "string" },
          quantity: { type: "number" },
          unit: { type: "string" },
          calories: { type: "number" },
          protein_g: { type: "number" },
          carbs_g: { type: "number" },
          fat_g: { type: "number" },
        },
      },
    },
    confidence: { type: "string", enum: ["low", "medium", "high"] },
    notes: { type: "string", description: "One sentence on portion-size assumptions or what was unclear." },
  },
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/estimate") {
      return json({ error: "Not found" }, 404);
    }

    const ip = request.headers.get("CF-Connecting-IP") ?? "unknown";
    const { success } = await env.RATE_LIMITER.limit({ key: ip });
    if (!success) {
      return json({ error: "Too many requests. Try again in a minute." }, 429);
    }

    let image;
    try {
      ({ image } = await request.json());
    } catch {
      return json({ error: "Request body must be JSON." }, 400);
    }
    if (typeof image !== "string" || image.length === 0 || image.length > MAX_IMAGE_BASE64_LENGTH) {
      return json({ error: "Missing or oversized image." }, 400);
    }

    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: env.MODEL,
        max_tokens: 2048,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: "user",
            content: [
              { type: "image", source: { type: "base64", media_type: "image/jpeg", data: image } },
              { type: "text", text: "Estimate the nutrition for this meal." },
            ],
          },
        ],
        output_config: { format: { type: "json_schema", schema: ESTIMATE_SCHEMA } },
      }),
    });

    if (!response.ok) {
      console.log(`Claude API error ${response.status}: ${await response.text()}`);
      return json({ error: "The estimate service is unavailable." }, 502);
    }

    const message = await response.json();
    const text = message.content?.find((block) => block.type === "text")?.text;
    if (message.stop_reason !== "end_turn" || !text) {
      console.log(`Unusable response, stop reason: ${message.stop_reason}`);
      return json({ error: "Could not estimate this photo." }, 502);
    }

    try {
      return json(JSON.parse(text));
    } catch {
      return json({ error: "Could not estimate this photo." }, 502);
    }
  },
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
