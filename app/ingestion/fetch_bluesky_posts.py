"""Append-only fetch of Discworld/Pratchett-related Bluesky posts into raw.bluesky_posts.

Checkpoint is BigQuery itself (MAX(created_at)) — safe to re-run anytime;
each run only pulls posts newer than what's already landed.
"""

import os
from datetime import datetime, timedelta, timezone

from atproto import Client
from dotenv import load_dotenv
from google.cloud import bigquery

PROJECT_ID = "dbt-pratchett"
DATASET = "raw"
TABLE = "bluesky_posts"
SEARCH_TERMS = ["Discworld", "Pratchett"]
BACKFILL_DAYS = 90
PAGE_LIMIT = 100
MAX_PAGES_PER_TERM = 50


def parse_created_at(value: str) -> datetime:
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def get_checkpoint(bq_client: bigquery.Client) -> datetime:
    query = f"SELECT MAX(created_at) AS max_created_at FROM `{PROJECT_ID}.{DATASET}.{TABLE}`"
    row = next(iter(bq_client.query(query).result()))
    if row.max_created_at is not None:
        return row.max_created_at
    return datetime.now(timezone.utc) - timedelta(days=BACKFILL_DAYS)


def search_new_posts(bsky_client: Client, checkpoint: datetime) -> dict:
    """Search newest-first per term, stopping each term as soon as posts are no newer than checkpoint."""
    posts_by_uri = {}

    for term in SEARCH_TERMS:
        cursor = None
        for _ in range(MAX_PAGES_PER_TERM):
            params = {"q": term, "sort": "latest", "limit": PAGE_LIMIT}
            if cursor:
                params["cursor"] = cursor
            response = bsky_client.app.bsky.feed.search_posts(params)

            if not response.posts:
                break

            reached_checkpoint = False
            for post in response.posts:
                created_at = parse_created_at(post.record.created_at)
                if created_at <= checkpoint:
                    reached_checkpoint = True
                    break
                rkey = post.uri.split("/")[-1]
                posts_by_uri[post.uri] = {
                    "post_uri": post.uri,
                    "author_did": post.author.did,
                    "author_handle": post.author.handle,
                    "text": post.record.text,
                    "created_at": post.record.created_at,
                    "permalink": f"https://bsky.app/profile/{post.author.handle}/post/{rkey}",
                }

            if reached_checkpoint or not response.cursor:
                break
            cursor = response.cursor

    return posts_by_uri


def load_rows(bq_client: bigquery.Client, rows: list) -> int:
    if not rows:
        return 0

    table_ref = f"{PROJECT_ID}.{DATASET}.{TABLE}"
    schema = [
        bigquery.SchemaField("post_uri", "STRING"),
        bigquery.SchemaField("author_did", "STRING"),
        bigquery.SchemaField("author_handle", "STRING"),
        bigquery.SchemaField("text", "STRING"),
        bigquery.SchemaField("created_at", "TIMESTAMP"),
        bigquery.SchemaField("permalink", "STRING"),
    ]
    job_config = bigquery.LoadJobConfig(
        schema=schema,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    )
    load_job = bq_client.load_table_from_json(rows, table_ref, job_config=job_config)
    load_job.result()
    return load_job.output_rows


def main():
    load_dotenv()

    bsky_client = Client()
    bsky_client.login(os.environ["BLUESKY_IDENTIFIER"], os.environ["BLUESKY_APP_PASSWORD"])

    bq_client = bigquery.Client(project=PROJECT_ID)

    checkpoint = get_checkpoint(bq_client)
    print(f"Checkpoint: fetching posts newer than {checkpoint.isoformat()}")

    posts_by_uri = search_new_posts(bsky_client, checkpoint)
    rows = list(posts_by_uri.values())
    print(f"Found {len(rows)} new post(s) across search terms {SEARCH_TERMS}")

    loaded = load_rows(bq_client, rows)
    print(f"Loaded {loaded} row(s) into {PROJECT_ID}.{DATASET}.{TABLE}")


if __name__ == "__main__":
    main()
