# Legal India AI: setup, features and tests

## Files
index.html (the site) · migration.sql (new tables, additive) · supabase/functions/ai-chat/index.ts (optional AI backend)

## Setup
1. Use a NEW Supabase project (recommended) so nothing existing is touched. I could not inspect your existing database; migration.sql only creates lia_* tables and a private bucket and changes nothing else. Back up first if you reuse a project.
2. SQL Editor: run migration.sql once.
3. Authentication > Email Templates > "Magic Link" (and "Confirm signup"): include the code with {{ .Token }} so users receive a 6-digit code.
4. Authentication > Providers > Email: on. Authentication > URL Configuration: set Site URL to your site.
5. In index.html set SB_URL and SB_KEY (Project URL and anon key only) at the top of the script.
6. Upload index.html to GitHub, deploy on Netlify/Vercel/GitHub Pages.
7. Optional AI: supabase functions deploy ai-chat; supabase secrets set ANTHROPIC_API_KEY=...; then in index.html set AI_FN="ai-chat".

## Environment variables / secrets
Frontend (index.html): SB_URL, SB_KEY (anon, public by design), AI_FN (function name).
Server only (Supabase secrets): ANTHROPIC_API_KEY, optional AI_MODEL. SUPABASE_URL and SUPABASE_ANON_KEY are provided automatically to functions. Never put service_role or the AI key in index.html.

## Working now
Chat-first home with attachments (file, photo, voice) and history; Gmail OTP register/login (needs steps 3-5); profile view/edit/photo/settings/sign out; three-mode switch (remembered); sidebars and bottom navigation; search; saved items; notifications from hearings and study tasks; FIR, rights, aid, cyber, women and child, consumer, schemes guides; generators (police complaint, RTI, consumer complaint, legal notice, bail, writ, contract); Bare Acts library with current vs repealed; landmark judgments; client, case, hearing, billing, notes, planner and progress records (private, RLS); private document upload; MCQ, viva, dictionary, moot, case brief and exam skeleton tools; language switch for menus.

## Needs external setup or provider
AI answers, research, case analysis, document explainer/analysis, translation, tutor, assignment help (AI function + key). Mobile OTP verification (SMS provider such as Twilio configured in Supabase). Court case status in-app, live legal news, lawyer directory, internship listings (data sources or APIs). Chat attachments are stored privately but not read without AI.

## Not built yet
Role approval or Bar Council enrolment verification for professionals; invoice PDFs; server-side calendar reminders (email/SMS); full translation of legal content.

## Tests
1. Open site as guest: chat shows; browse Know Your Rights without signing in.
2. Ask a question: registration appears; register; receive the code; verify; answer appears; profile shows photo, name, mobile, Gmail.
3. Sign out, log in with Gmail code; history lists the earlier chat.
4. Switch modes; reload; the mode is remembered.
5. Professional: add a client, a case and a hearing within 7 days; bell shows 1; Home shows counts.
6. Upload a document in Document Analysis; open it; delete it.
7. In Supabase use a second account: confirm it cannot see the first account's rows (Table Editor with RLS, or API as that user).

## Update: paid Professional and Student modes (Rs 99 for 6 months)
- Citizen mode and the chat assistant are free after login.
- Professional needs name, mobile, email (from the profile) plus Bar Council enrolment ID. Student needs college name and roll number.
- Run migration_2.sql after migration.sql. A registration creates a PENDING row; users cannot activate themselves.
- Payment is NOT integrated (needs a gateway such as Razorpay plus a server webhook). Until then, activate in Supabase with the SQL at the bottom of migration_2.sql after you verify the details and receive payment.
- Server-side, professional and student records are blocked without an active membership.
- Test: register as Professional, see "Pending"; activate in SQL; reload and the workspace opens; set paid_until to a past date and it shows "Expired".
- The Explore button was removed; all tools are in the left menu.

## Update: 3-day free trial, then pay first
- Registering (Bar Council enrolment ID, or college name and roll number) starts a one-time 3-day free trial for that mode. The server sets the dates and users cannot restart a trial or delete the row.
- After the trial the mode locks. The user pays Rs 99 and submits a transaction reference plus a screenshot; status becomes payment_review. You verify, then run the activation SQL at the bottom of migration_3.sql (gives 6 months).
- Run migration_3.sql after migration_2.sql. In index.html set PAY_UPI to your UPI ID (until then the page says payment details are not configured). Payment screenshots are stored privately in lia-docs/<user id>/payment/.
- Limits: a trial is not verified first, so someone could register extra accounts for more trials; verify before activating paid access. Real automatic payment needs a gateway such as Razorpay.
- Test: register Professional, trial starts; in SQL set trial_until to yesterday, reload, mode shows "Trial ended"; submit proof, shows "Under review"; run the activation SQL, mode opens.

## Update: Professional and Student modes are free for now
- Payment, the 3-day trial and the UPI box are switched off (FREE_MODE=true at the top of index.html). Users still fill the proof form (Bar Council enrolment ID, or college name and roll number) and then use the mode.
- Run migration_4.sql in the SQL Editor (after migration.sql and migration_2.sql; migration_3.sql is optional). It lets any registered, non-rejected user in on the server side.
- You do not need PAY_UPI now. To bring payment back later: set FREE_MODE=false, add PAY_UPI, and re-run the lia_can function from migration_3.sql.
- Test: switch to Professional, fill the form, the dashboard opens at once. Add a client; reload; it is still there.

## Update: Professional and Student modes are FREE for now
- In index.html, FREE_MODE=true hides the trial and payment screens. Users register once with proof details (Professional: Bar Council enrolment ID; Student: college name and roll number) and get access.
- Run migration_4.sql after migrations 1, 2 and 3. Free access lasts until the date in public.lia_settings (free_until, set to 2027-05-31). Change it with: update public.lia_settings set value = '2027-12-31' where key = 'free_until'; (people who already registered keep the date they got).
- To bring payments back later: set FREE_MODE=false (the trial and UPI payment screens are still in the file) and tell new users the fee.
- Test: sign in, switch to Professional, fill the form, tools open at once. In Table Editor > lia_memberships the row shows status active.
