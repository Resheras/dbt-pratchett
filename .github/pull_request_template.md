## What & why

<!-- One or two sentences: what this PR changes and which milestone it belongs to. -->

Milestone:

## Changes

<!-- Bullet the models / macros / tests / docs added or changed. -->

-

## Self-review checklist

- [ ] `dbt build` (or `dbt run` + `dbt test`) passes green locally
- [ ] New/changed models use `ref()` / `source()`, not hardcoded table paths
- [ ] No trailing semicolon at the end of any model file (breaks BigQuery's `CREATE OR REPLACE VIEW ... AS (...)` wrapper)
- [ ] Incremental models: if a model's **shape** changed (column renamed/added/dropped), ran a `--full-refresh`
- [ ] New columns/models have a `description:` in the schema YAML
- [ ] Verified output against BigQuery directly (`bq ls` / `bq query`), not just "the model file looks right"
- [ ] Row counts / grain are sane and match expectations
- [ ] Scope is limited to this milestone — no unrelated changes

## Verification notes

<!-- How you confirmed it works: row counts, spot-checks, a deliberately-broken test that went red, etc. -->
