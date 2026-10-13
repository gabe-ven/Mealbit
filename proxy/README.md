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

To point the app at it, temporarily set `MealEstimator.endpoint` to
`http://localhost:8787/estimate` (works in the simulator only).

## Deploy (for real phones)

1. `npx wrangler login`
2. `npx wrangler secret put ANTHROPIC_API_KEY` and paste the key.
3. `npm run deploy`

The app calls the deployed Worker at
`https://mealbit-proxy.mealbit.workers.dev/estimate` (set in
`Mealbit/Mealbit/Services/MealEstimator.swift`). To change the key later, run
step 2 again; no redeploy is needed.

## Test with curl

```
python3 -c "import base64,json,sys;print(json.dumps({'image':base64.b64encode(open(sys.argv[1],'rb').read()).decode()}))" meal.jpg > req.json
curl -X POST localhost:8787/estimate -H 'content-type: application/json' --data @req.json
```

The model is set by `MODEL` in `wrangler.toml`.
