# Mealbit Proxy

A Cloudflare Worker that holds the Claude API key so the iOS app never does.
The app sends one meal photo to `POST /estimate` and gets back the meal name
and its components with estimated nutrition.

Each IP address can make at most 10 requests per minute. Also set a monthly
spend limit for your key in the Claude Console, since the URL is public.

## Run locally (for the simulator)

1. `npm install`
2. Create `.dev.vars` in this folder (it is git-ignored):

   ```
   ANTHROPIC_API_KEY=your-key-here
   ```
3. `npm run dev`

The simulator build of the app calls `http://localhost:8787/estimate`.

## Deploy (for real phones)

1. `npx wrangler login`
2. `npx wrangler secret put ANTHROPIC_API_KEY` and paste the key.
3. `npm run deploy`. Wrangler prints the Worker URL, such as
   `https://mealbit-proxy.<your-subdomain>.workers.dev`.
4. Put that URL in `MealEstimator.endpoint` (the non-simulator branch) in
   `Mealbit/Mealbit/Services/MealEstimator.swift`.

## Test with curl

```
python3 -c "import base64,json,sys;print(json.dumps({'image':base64.b64encode(open(sys.argv[1],'rb').read()).decode()}))" meal.jpg > req.json
curl -X POST localhost:8787/estimate -H 'content-type: application/json' --data @req.json
```

The model is set by `MODEL` in `wrangler.toml`.
