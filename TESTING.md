# End-to-End Testing Guide (Seed Data)

This guide walks through manually testing the app end-to-end using the accounts and
records created by `db/seeds.rb`. No extra setup beyond seeding is required.

## 1. Setup

```bash
bin/rails db:prepare   # create + migrate dev DB
bin/rails db:seed      # load sample data (idempotent, safe to re-run)
bin/dev                # start rails server + css watcher
```

Default credentials (override via `SUPER_ADMIN_EMAIL` / `SUPER_ADMIN_PASSWORD` /
`SAMPLE_USER_PASSWORD` env vars if changed):

- Super admin password: `KramaAdmin123!`
- All sample forum users password: `SamplePass123!`

## 2. Seeded accounts

| Role | Forum | Example email |
|---|---|---|
| super_admin | — | `admin@kramaconsultancy.com` |
| forum_admin | riverside-traders (active) | `admin@riverside-traders.example.com` |
| forum_admin | metro-business-guild (trial) | `admin@metro-business-guild.example.com` |
| forum_admin | coastal-merchants (suspended) | `admin@coastal-merchants.example.com` |
| chapter_admin | riverside-traders / Downtown | `chapter-admin-1@riverside-traders.example.com` |
| committee_member | riverside-traders / Downtown | `committee-1@riverside-traders.example.com` |
| member | riverside-traders / Downtown | `member-1-1@riverside-traders.example.com`, `member-1-2@...` |
| guest | riverside-traders | `guest@riverside-traders.example.com` |

Same pattern applies to `metro-business-guild` (chapters: Uptown, Westside → index 1, 2)
and `coastal-merchants` (chapter: Old Town → index 1) — swap the domain and index.

## 3. Scenarios

### A. Super Admin (`admin@kramaconsultancy.com`)
- [ ] Log in → lands on `/super_admin/dashboard`.
- [ ] `/super_admin/forums` — all 3 seeded forums show correct status (active/trial/suspended).
- [ ] Suspend `riverside-traders`, then re-activate it.
- [ ] Activate `coastal-merchants` (currently suspended in seed data).
- [ ] Change `riverside-traders`'s plan (Bronze/Gold/Diamond).
- [ ] Impersonate the `metro-business-guild` forum admin, verify landing page, end impersonation.
- [ ] Reset password / force logout a forum admin.
- [ ] `/super_admin/plans` — edit, archive, reactivate a plan.
- [ ] `/super_admin/subscriptions` — extend trial, change renewal date for `metro-business-guild`.
- [ ] `/super_admin/users` — suspend/unsuspend/force-logout a member.
- [ ] `/super_admin/forum_requests` — approve/reject (see scenario C to generate one).
- [ ] `/super_admin/announcements` — create + publish, confirm it appears to forum users.
- [ ] `/super_admin/reports` — check all tabs: forums, users, invoices_payments, attendance, referrals_business.
- [ ] `/super_admin/support_tickets` — reply + change status (see scenario E to generate one).

### B. Forum Admin (`admin@riverside-traders.example.com`)
- [ ] Log in → lands on `/f/riverside-traders/dashboard`; confirm no visibility into other forums.
- [ ] Chapters: create a 4th chapter, assign an admin, activate it.
- [ ] Members: create, edit, suspend, activate, reset password, force logout, renew, print.
- [ ] Committee members: add/edit/remove.
- [ ] Guests: add a guest, convert to member (role + chapter should carry over).
- [ ] Fee payments: create, mark paid, print receipt.
- [ ] Meetings / weekly presentations / attendances: create and list each.
- [ ] Referrals: create between two seeded members, accept, add a thanksgiving slip.
- [ ] One-to-one meetings: request, accept, complete.
- [ ] Events: create, register a member, view registrations. Office darshans: create/list.
- [ ] Finance/expenses: add an expense, view `/f/riverside-traders/finance`.
- [ ] Documents: upload, list, delete.
- [ ] Announcements: create/publish, confirm members see it in notifications.
- [ ] Settings/profile: update settings, force-logout-others from profile.
- [ ] Analytics + all report tabs (members, guests, attendance, referrals, business_generated, chapters, meetings, events, renewals) render without error.

### C. Forum request → approval flow
- [ ] Logged out: submit `/forum_requests/new`.
- [ ] As super admin: approve it → confirm new Forum + forum_admin user created.
- [ ] Submit a second request and reject it → confirm no forum is created.

### D. Trial / suspended forum behavior (uses seeded status variety)
- [ ] Log in as `admin@metro-business-guild.example.com` (trial) — trial banners/limits appear.
- [ ] Log in as `admin@coastal-merchants.example.com` (suspended) — access blocked / suspended notice shown, not a normal dashboard.
- [ ] Set `riverside-traders` to Bronze plan (member_limit: 3). Seed data already has 6 members (2 × 3 chapters) — verify creating a 7th member is blocked with a clear limit error.

### E. Chapter Admin / Committee Member / Member / Guest (scoped access)
- [ ] `chapter-admin-1@riverside-traders.example.com` — only sees Downtown, not Harborview/North Ridge.
- [ ] `committee-1@riverside-traders.example.com` — confirm permissions differ from chapter admin.
- [ ] `member-1-1@riverside-traders.example.com` — view profile, submit a referral, submit a support ticket, register for an event, check notifications.
- [ ] Forum admin replies to that ticket; member sees the reply.
- [ ] `guest@riverside-traders.example.com` — confirm more restricted access than member (e.g. no chapter dashboard).

### F. Cross-forum isolation (negative test)
- [ ] As `admin@riverside-traders.example.com`, navigate directly to a `metro-business-guild` URL (e.g. `/f/metro-business-guild/members`) — must be denied/redirected, never 200 with data.
- [ ] Repeat for a member trying another forum's chapter URLs.

### G. Auth edge cases
- [ ] Devise sign-in / sign-out / forgot-password for a seeded user.
- [ ] Force-logout from super admin invalidates that user's active session immediately (verify with two sessions/incognito).

## 4. Automation

`test/system` is currently empty (`.keep` only) even though `capybara` and
`selenium-webdriver` are in the Gemfile. Good first candidates to automate:
role/forum isolation (scenario F) and the plan member-limit case (scenario D, third item),
since those are the highest-risk correctness bugs and easiest to regress silently.
