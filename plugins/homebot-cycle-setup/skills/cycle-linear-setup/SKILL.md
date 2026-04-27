---
name: cycle-linear-setup
description: Use when the user asks to set up Linear for a new Homebot Shape Up cycle, kick off a cycle in Linear, create cycle projects, or invokes /cycle-linear-setup. Pulls the cycle brief from Notion, finds pitches the user drives, and creates one Linear project per pitch with milestones derived from the pitch.
---

# Homebot Cycle Linear Setup

## Overview

At the start of each Homebot Shape Up cycle, create one Linear project per pitch the user drives. Notion pitches are canonical; Linear projects link back. The skill confirms scope upfront, gathers any missing milestone judgment, then writes everything in one batch.

See [reference.md](reference.md) for the Domain→team map, Triad→initiative map, and field defaults.

**Required MCPs:** Notion (`mcp__claude_ai_Notion__*` or equivalent), Linear (`mcp__claude_ai_Linear__*` or equivalent). If either is unavailable, fail loudly and tell the user to re-auth.

## Phase 1 — Identify the user, gather and confirm scope

1. **Discover the current user's identity.** Required to filter pitches by Driver.
   - If env var `HOMEBOT_USER_EMAIL` is set, use it.
   - Otherwise prompt the user once: "What's your @homebot.ai email?" Suggest setting `HOMEBOT_USER_EMAIL` in their shell profile to skip this prompt next time.
   - Resolve the user's Notion user ID by calling `notion-search` with `query_type: user` and the email as the query. Cache the ID in memory for the run.

2. **Determine cycle number.** Default = current. If unclear, ask the user.

3. **Find the brief.** Search Notion for `R&D Cycle <N>-<YY> Brief` where `<YY>` is the current year's last two digits (e.g., `R&D Cycle 3-26 Brief`). Show the user the title and confirm. If not found, ask the user for the correct title or URL.

4. **Query the Pitches Database** for committed bets the user drives:
   - Data source: `collection://d06fea27-fa6c-44b5-84fa-a5e6f93c0fec`
   - Filters: `Brief = C<N>-<YY>`, `Cycle = C<N>-<YY>`, `Status IN ('Ready', 'Bet')`, `Driver` contains the user's Notion ID
   - **Why both Ready and Bet:** at cycle kickoff, committed bets are still in `Ready` in Notion. The team flips Notion `Status: Ready → Bet` as projects are dialed in (separate from the Linear project status flip). On-deck pitches have `Cycle = 'On Deck'` so the Cycle filter excludes them.
   - Use `notion-query-data-sources` with SQL: `SELECT ... WHERE Brief = ? AND Cycle = ? AND Status IN ('Ready','Bet') AND Driver LIKE '%<user-notion-id>%'`.

5. **Surface On Deck pitches** where the user is driver — list as "skipped (on deck)".

6. **Print a numbered confirmation block** with pitch title, Domain, Appetite. Wait for `y / edit / cancel`. **No writes until confirmed.**

## Phase 2 — Per-pitch fetch and milestone interaction

7. After confirmation, parallel `notion-fetch` each pitch URL.

8. For each pitch body, scan for an explicit scope section. Heading heuristic: `Scopes`, `Milestones`, `Plan`, `Solution Direction`, `Fat Marker`. If found with a list under it, use as-is. Also scan the **Boundaries → In** section: scope items there often map back to the milestones and should be attached to the corresponding milestone description. Preserve the pitch's formatting — bulleted lists stay bulleted, numbered lists stay numbered, sub-bullets stay nested. Each milestone's Linear description should fully capture what's in that milestone, not just a summary line.

9. If no explicit list, draft 3-4 milestone candidates based on pitch context. Drafting principles:
   - Short imperative names (e.g., "Auto-favorite all partners shipped to beta")
   - Each carries a one-line user-value framing
   - Sequence ships value early and iteratively, not waterfall
   - First milestone is the smallest end-to-end slice that's user-visible

10. Batch-prompt the user with one block covering all pitches needing milestone help. They accept/edit/replace per pitch. Loop until all approved.

## Phase 3 — Linear creation

For each confirmed pitch in parallel:

1. Resolve team via `list_teams` using Domain map ([reference.md](reference.md)).
2. Resolve initiatives via Triad map.
3. Resolve member user IDs via `list_users` (email match preferred). Skip unresolved members; collect as gap.
4. Idempotency: `list_projects` on the team filtered by exact title match. If found, skip and report the existing URL.
5. `save_project` with: name (pitch title), team, lead = `me` (the connected Linear user), members, priority (Stakes map), initiatives, start date, target date, summary, description, status = **Shaped**, **icon**.

   **Icon picking:** pick an emoji that captures the pitch's core verb or outcome (not the team or domain). Aim for something distinctive — Linear team icons are already varied, so the project icon should differentiate the bet, not duplicate the team. Avoid generic icons (`:rocket:`, `:sparkles:`, `:fire:`) — they get overused. Examples:
   - "Give Me 3 Clients to Call Today v2" → `:telephone_receiver:` (the action: calling a client)
   - "Auto-Match v2" → `:handshake:` (the outcome: a quality partner-client match)
   - "Partner Data in the Semantic Layer" → `:building_construction:` (the architectural lift)
   Pass the icon as `:emoji_name:` format to `save_project`.

6. `save_milestone` for each approved scope, in order. **Names capped at 80 characters — trim before calling.**
7. Per-pitch failures don't abort the batch — collect and report.

Two project fields:
- **`summary`** = pitch's `Done` outcome verbatim. This is the short subtitle under the project title in Linear (max 255 chars). Trim if longer.
- **`description`** = pitch + cycle brief links:
  ```
  **Pitch:** [<pitch title>](<pitch URL>)
  **Cycle brief:** [R&D Cycle <N>-<YY> Brief](<brief URL>)
  ```

The pitch is canonical; the description is just resource navigation. The Done outcome belongs in `summary` so it shows everywhere a project is referenced.

## Phase 4 — Post-creation review

Print a summary table:

| Pitch | Linear URL | Milestones | Assumptions / Gaps |
|---|---|---|---|

Then prompt:
> Review in Linear, dial in any gaps, then flip Status from Shaped to Bet on each.

Offer to bulk-flip Status → Bet, default declined. User confirms when ready.

## Edge cases

- **Empty Domain** — halt that pitch, ask which team.
- **Empty Triad** — create without initiative; flag.
- **Linear user not found** — skip member; flag.
- **Existing project with same name in target team** — skip; report existing URL.
- **Brief not found** — ask the user for title or URL.
- **Notion or Linear MCP unavailable** — fail loudly; instruct the user to re-auth.

## Known Linear MCP quirks

- **`state` param may be ignored on `save_project`** — the project may land in `Backlog` regardless of what's passed. Workaround: create the project, then immediately update with the team's actual project-status name (e.g., `Shaped`). Look up via the Linear team's project statuses (Homebot's "How We Use Linear" doc says these are standardized at the parent-team level). If unsure, leave as Backlog and flag — the user will set during review.
- **Milestone names are capped at 80 characters.** Trim before calling `save_milestone`. Reword to keep meaning; do not truncate mid-word.
- **Notion → Linear user mapping is not deterministic** from the pitch's user ID alone. Resolve only the Driver (the user invoking the skill, who is the project lead = `me` in Linear). Tech Lead and Dependent Leads should be flagged as gaps for the post-creation review unless the user confirms inline.

## What to surface as assumptions

- "Tech Lead missing — only Driver added as member"
- "Triad empty — no initiative attached"
- "Pitch has no explicit Scopes section — milestones drafted by Claude"
- "Multi-Triad → attached to N initiatives"
- "Member <name> not found in Linear — skipped"
