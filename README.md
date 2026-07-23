# dbt-pratchett

A portfolio dbt project analyzing Discworld novels alongside live Bluesky posts mentioning Discworld/Pratchett, built on BigQuery.

## Stack

- **Warehouse:** BigQuery (Always Free tier)
- **Transformation:** dbt-core (CLI, local)
- **Sources:** `dysk 2.csv` (Discworld novel metadata) + live Bluesky posts via the AT Protocol
- **Semantic layer:** MetricFlow (via dbt-core)
- **Workflow:** git + GitHub, PR-per-milestone

## Roadmap / Future work

**AI-based post classification (not yet implemented):** matching a Bluesky post to a specific book/series is currently planned as regex/keyword matching in `int_bluesky_post_matches`. A better approach would be classifying posts with an LLM (e.g. BigQuery ML's `AI.GENERATE` calling Vertex AI Gemini) instead of pattern matching. This is deferred to a later stage, run once against clean mart-level data rather than raw posts, because Vertex AI calls are billed and fall outside BigQuery's free tier that the rest of this project relies on.
