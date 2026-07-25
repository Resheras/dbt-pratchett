{% docs year_forward_fill %} 
The source CSV records a publication year only on the first book of each year; later books that year have a blank year cell. This column carries the last known year forward (`LAST_VALUE(... IGNORE NULLS)` ordered by `order_of_release`) so every book has a year. The companion `year_inferred` flag marks which rows were filled this way rather than sourced directly, keeping the imputation auditable. 
{% enddocs %}  

{% docs post_matching %} 
Posts are matched to books and series by scanning the post text for the title or series name — case-insensitive, anchored on word boundaries (`\b`) so a short title can't match inside a larger word (e.g. "Mort" won't fire on "immortal"). Matching is many-to-many: a post can mention several books and several series, and a post that mentions nothing produces no match rows (it is **not** dropped — the fact table stays at full post grain). This is deliberately a keyword match, not semantic, so it can occasionally false-positive on title collisions (a different book literally titled "Night Watch"). An AI-classification pass is noted as future work. 
{% enddocs %}  

{% docs incremental_merge_strategy %} 
`fct_bluesky_posts` is incremental with `incremental_strategy='merge'` on `post_uri`, not `append`. Each run re-processes a trailing look-back window (`created_at >= max - 3 days`) rather than a strict "> max" cutoff, because Bluesky can deliver posts slightly out of order and a strict cutoff could skip a late-arriving post forever. A look-back window means the same post can be re-selected on a later run, so `merge` (upsert on `post_uri`) makes that a harmless no-op — `append` would create duplicates. The table is partitioned by `created_at` (day granularity) so the window only scans recent partitions.
{% enddocs %}