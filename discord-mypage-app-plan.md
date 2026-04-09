# Discord MyPage App – Product & Technical Blueprint

## 1) Product vision
Build a **Discord-native profile extension** where each member in your server has a polished “MyPage” that highlights:
- Verified achievements/awards
- Professional bio and role badges
- Portfolio links and featured projects
- A personalized “For You” feed (recommended people, content, opportunities)

Because Discord does not allow replacing the default profile panel globally, the best implementation is:
1. A **Discord App/Bot** with slash commands + context menus.
2. A **web app** that renders each user’s full MyPage.
3. Discord profile/context entry points that open the MyPage link.

---

## 2) What users should experience

### Member flow
1. Member runs `/mypage setup`.
2. Bot opens a guided setup (modals/buttons) to fill profile fields.
3. Member adds awards, links, and “featured” content.
4. Member gets a public MyPage URL (`https://yourdomain.com/u/<handle>`).

### Viewer flow
1. In your server, a user clicks a profile action like **View MyPage** (context command/button).
2. Bot responds with an ephemeral embed containing the MyPage preview and link.
3. Viewer can open the full page with tabs:
   - Overview
   - Awards
   - Portfolio
   - For You

### Moderator/admin flow
1. Staff reviews pending awards.
2. Staff approves/rejects with reason.
3. Approved awards are marked verified and visible publicly.

---

## 3) MVP scope (first 4–6 weeks)

### Core MVP features
- Discord OAuth sign-in
- Profile editing (name, headline, bio, links)
- Awards CRUD (add/edit/delete)
- Award verification workflow (pending/approved/rejected)
- Public profile page + Discord embed preview
- Basic For You recommendations (rule-based)

### Non-goals (MVP)
- Real-time AI ranking models
- Multi-server federation
- Advanced analytics dashboards

---

## 4) Recommended architecture

### Stack (fast + reliable)
- **Frontend:** Next.js (App Router) + Tailwind
- **Backend/API:** Next.js API routes or NestJS (if you want stricter domain separation)
- **Database:** PostgreSQL + Prisma
- **Cache/queue (optional MVP):** Redis + BullMQ
- **Discord integration:** discord.js
- **Auth:** Discord OAuth2
- **Hosting:** Vercel (frontend/API) + managed Postgres (Neon/Supabase/RDS)

### High-level components
1. **Discord Bot Service**
   - Slash commands, context commands, modals
   - Sends links/previews to MyPage
2. **Application API**
   - Profile, award, recommendation endpoints
   - Role-based admin/mod endpoints
3. **Web UI**
   - Member dashboard (edit profile)
   - Public MyPage (read-only)
4. **Data Layer**
   - User profiles, awards, proof artifacts, recommendations

---

## 5) Data model (starter)

### `users`
- `id` (uuid)
- `discord_id` (unique)
- `username`
- `avatar_url`
- `headline`
- `bio`
- `created_at`
- `updated_at`

### `profiles`
- `id` (uuid)
- `user_id` (fk users)
- `slug` (unique)
- `theme`
- `is_public` (bool)

### `awards`
- `id` (uuid)
- `user_id` (fk users)
- `title`
- `issuer`
- `issued_at`
- `description`
- `proof_url`
- `status` (pending | approved | rejected)
- `reviewed_by` (fk users, nullable)
- `reviewed_at`

### `portfolio_items`
- `id` (uuid)
- `user_id` (fk users)
- `title`
- `url`
- `summary`
- `sort_order`

### `recommendations`
- `id` (uuid)
- `user_id` (target)
- `type` (people | content | opportunity)
- `entity_id`
- `reason`
- `score`
- `generated_at`

---

## 6) Discord interaction design

### Commands
- `/mypage setup`
- `/mypage view @user`
- `/award add`
- `/award list @user`
- `/award review <award_id> <approve|reject>` (mod/admin only)

### Context menu
- User context: **Open MyPage**

### Embeds
- Profile summary card
- Top 3 awards
- “Open full page” button

---

## 7) “For You” page (progressive approach)

### Phase 1 (rules)
- Recommend members with shared tags/interests
- Recommend high-signal community posts
- Recommend opportunities based on role + skills

### Phase 2 (personalized scoring)
- Implicit behavior: clicks, likes, saves
- Explicit signals: follows, favorite tags
- Ranking formula with freshness + diversity penalties

### Phase 3 (ML-assisted)
- Content embeddings
- Similarity search + reranking

---

## 8) Security, trust, and moderation

- Use Discord OAuth scopes minimally.
- Verify guild membership before allowing edit actions.
- Add anti-abuse limits (rate limits, cooldowns).
- Audit log all moderation actions on awards.
- Require proof links or attachments for “verified” badge eligibility.
- Implement privacy controls (`is_public`, field visibility toggles).

---

## 9) Build order (practical)

1. Create Discord app + bot and register slash commands.
2. Set up OAuth sign-in and user table.
3. Build profile edit/view pages.
4. Add award CRUD and moderation approval.
5. Add `/mypage view` and context menu link.
6. Add baseline “For You” recommendations.
7. Add analytics/events and iterate.

---

## 10) Success metrics

- Profile completion rate (7-day)
- Weekly active profile viewers
- Number of verified awards per 100 users
- Click-through rate on For You recommendations
- Retention: D7 and D30 of creators and viewers

---

## 11) Example 2-week sprint plan

### Sprint 1
- Discord app setup + `/mypage setup`
- OAuth + profile schema
- Public MyPage skeleton

### Sprint 2
- Awards CRUD + moderation queue
- `/mypage view` + embed previews
- For You v1 rules and tracking events

---

## 12) Next step you can take today

- Ship a tiny vertical slice:
  1. `/mypage setup`
  2. Save bio/headline
  3. `/mypage view @user` returns embed + public link

This gets real users testing quickly, then you can layer in awards verification and For You ranking.
