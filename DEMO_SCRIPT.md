# Demo Script — Business Network Forum

A step-by-step walkthrough to demo the app's main features in the UI: super admin login, creating a forum, membership application, and member login.

## 0. Setup

```
bin/rails db:seed
bin/dev
```

Open http://localhost:3000

## 1. Login as Super Admin

- Go to `/users/sign_in`
- Email: `admin@kramaconsultancy.com`
- Password: `KramaAdmin123!`

You land on the Super Admin dashboard (`/super_admin/dashboard`).

## 2. Create a Forum (as Super Admin)

- Go to `/super_admin/forums` → **New Forum**
- Fill in name/slug/plan and save
- This auto-creates a `forum_admin` user for that forum (shown once — copy the password)

> Alternative: instead of creating directly, show the public **request a forum** flow at `/forum_requests/new`, then approve it from `/super_admin/forum_requests`. Approving creates the forum + admin the same way.

## 3. Public visitor applies to join the forum

- Sign out
- Go to the forum's public page: `/<forum_slug>/apply`
- Fill in the membership application (name, email, phone, business info) and submit

## 4. Forum Admin approves the application

- Sign in as the forum's admin (email from step 2)
- Go to `/<forum_slug>/membership_applications`
- Open the pending application → **Approve** → pick a chapter
- This creates a `member` user with a temp password (shown once — copy it)

## 5. Login as the new Member

- Sign out, sign in with the member credentials from step 4
- Explore the member dashboard: chapters, meetings, events, leads, referrals

## 6. Bonus: Super Admin impersonation

- Sign back in as `admin@kramaconsultancy.com`
- Go to `/super_admin/forums` → open a forum → **Impersonate Admin**
- Shows how support can log in as a forum admin without knowing their password
- **Exit impersonation** to return to the super admin session

## Seeded demo data (from `db/seeds.rb`)

| Role | Forum | Email | Password |
|---|---|---|---|
| Super Admin | — | `admin@kramaconsultancy.com` | `KramaAdmin123!` |
| Forum Admin | riverside-traders | `admin@riverside-traders.example.com` | `SamplePass123!` |
| Member | riverside-traders | `member-1@riverside-traders.example.com` | `SamplePass123!` |
| Guest | riverside-traders | `guest@riverside-traders.example.com` | `SamplePass123!` |

(Other sample forums: `metro-business-guild` (trial), `coastal-merchants` (suspended) — same password pattern.)
