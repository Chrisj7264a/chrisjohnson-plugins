# cycle-linear-setup — Reference

## Notion source IDs (Homebot workspace)

- **Pitches Database** — `de5aabd4-caa8-41d3-81b0-7ff3c81dec64`
- **Pitches Data Source** — `collection://d06fea27-fa6c-44b5-84fa-a5e6f93c0fec`
- **Prod Team Home** (parent) — `2eda359d-8a55-817d-927a-f17a6aab92f9`
- **How We Use Linear** — `319a359d-8a55-80bc-a946-cecba6533366`

## Pitches DB property names (exact, copy verbatim)

`Pitch`, `Driver`, `Tech Lead`, `Dependent Leads` (note: leading + trailing spaces in real schema), `Domain`, `Triad`, `Stakes`, `Appetite`, `Cycle`, `Brief`, `Status`, `Done`, `Horizon`, `Needs Design`.

## Domain → Linear team

| Notion Domain | Linear team name | Linear team ID |
|---|---|---|
| Messaging | User Messaging | `5fc180e9-61b2-4deb-9c70-a78fbba201da` |
| VSB | VSB | `fb1c40b2-b12d-42d9-99bd-427f75fe39bf` |
| Intelligence | Intelligence | `942d6c62-8869-4a13-8497-9b1f30d3e6ed` |
| CustomerX | Customer Experience | `5f22fb4a-0446-44c1-b4d0-736d911a1635` |
| ClientX | Client Experience | `d27c72a8-7fc8-4963-8903-124768ef07a2` |
| Enterprise | Enterprise | `c9b1bdbd-de1b-46e3-8133-b30a67684663` |
| Data | Data | `06a0a534-ea42-4816-bd14-eb34019f1cd0` |
| Infra | Infrastructure | `0ef4b155-f1c3-43ae-b38d-6ab4d09e0ca8` |
| Design | Design | `bb537efb-0cc1-4f2a-acc3-3c1ab96d48c6` |

Resolve at runtime via `list_teams` — IDs above are cache, names are contract.

## Triad → Linear initiative

| Notion Triad | Linear initiative | Initiative ID |
|---|---|---|
| Load | Load | `8ec44e62-d17d-485f-a5a3-fadce570ccbd` |
| Engage | Engage | `5ec3244d-604a-40da-a217-4555fe30a43d` |
| Act | Activate | `51b3de3a-5c6c-454a-9854-94df9c628ea8` |

Multi-Triad pitches attach to all matching initiatives.

## Stakes → Priority

| Stakes | Linear priority |
|---|---|
| Must | High (2) |
| Should | Medium (3) |
| Could | Low (4) |
| Maybe | No priority (0) |

## Default project fields

- **Name** = pitch title (verbatim)
- **Lead** = `me` (the connected Linear user — same person invoking the skill)
- **Members** = Driver + Tech Lead + Dependent Leads (skip empty, skip unresolved Notion→Linear matches)
- **Status** = `Shaped` on creation (user flips to `Bet` after review)
- **Start date** / **Target date** = parsed from cycle brief ("Cycle dates: ..."). Ask the user if parsing fails.
- **Summary** = pitch's `Done` outcome verbatim (max 255 chars; trim if longer). Appears under the project title in Linear.
- **Description** = pitch + cycle brief navigation links only.
  ```
  **Pitch:** [<pitch title>](<pitch URL>)
  **Cycle brief:** [R&D Cycle <N>-<YY> Brief](<brief URL>)
  ```

## Linear MCP tools used

- `list_teams` — verify team IDs
- `list_initiatives` — verify initiative IDs
- `list_users` — resolve member emails to user IDs
- `list_projects` — idempotency check
- `save_project` — create the project
- `save_milestone` — create each milestone

## Notion MCP tools used

- `notion-search` — find brief, find current user (via `query_type: user`), filter pitches
- `notion-fetch` — pull pitch bodies for milestone parsing
- `notion-query-data-sources` — SQL filter on the Pitches DB
