# Contributing / Workflow

This repo is developed with a git-based engineering workflow — one feature branch
per milestone, opened as a pull request, self-reviewed against a checklist, and
squash-merged into a protected `main`. `main` is never committed to directly.

## Branch-per-milestone flow

```
git checkout main
git pull                                   # start from up-to-date main
git checkout -b milestone-N-short-name     # feature branch for the milestone

# ...write models / macros / tests / docs, run dbt locally...

git add <files>
git commit -m "..."                        # commit in logical chunks
git push -u origin milestone-N-short-name  # push branch to GitHub

gh pr create                               # open the PR (fills in the template)
# ...self-review against the PR checklist, wait for CI once it exists...

gh pr merge --squash --delete-branch       # squash-merge, delete the branch
git checkout main && git pull              # return to a clean, current main
```

## Pull requests

- Every change reaches `main` through a PR — no direct pushes to `main`.
- PRs use the template in [`.github/pull_request_template.md`](.github/pull_request_template.md):
  a short what/why, the list of changes, a self-review checklist, and verification notes.
- Self-review means actually working the checklist before merging — including
  verifying model output against BigQuery directly, not just eyeballing the SQL.
- Merges are **squash** merges, so `main`'s history stays one commit per milestone.
- The feature branch is deleted after merge (locally and on GitHub).

## Branch protection on `main`

`main` is protected on GitHub with:

- **Require a pull request before merging** — direct pushes to `main` are rejected.
- **Do not allow bypassing the above settings** (no admin bypass) — the rule
  applies to the repo owner too, so the PR flow is enforced, not just conventional.

Once CI exists (milestone 11), a required **status check** will be added here so a
PR cannot be merged until `dbt build` / `dbt test` passes.
