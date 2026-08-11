# Sales CRM — GitHub + Supabase

This is the deployment-ready version of the Sales CRM.

## Architecture

- GitHub: source code and GitHub Pages hosting.
- Supabase: central Postgres database + user authentication + Row Level Security.
- Agents: log in and work only on their assigned leads/sales.
- Manager: can see the whole team's leads, pipeline and sales.

GitHub Pages is static hosting, so the live multi-user data is stored in Supabase.

## 1. Create the Supabase project

Create a project at https://supabase.com/

Open **SQL Editor** and run `schema.sql`.

## 2. Create users

In Supabase go to **Authentication → Users** and create the manager and agent accounts.

For each Auth user, copy their UUID.

Then in SQL Editor run examples like:

insert into public.profiles(id, full_name, role)
values ('AUTH-UUID', 'Your Name', 'manager');

insert into public.profiles(id, full_name, role)
values ('AUTH-UUID', 'Manan', 'agent');

Repeat for all agents.

## 3. Connect the frontend

Open `index.html`.

Replace:

YOUR_SUPABASE_URL
YOUR_SUPABASE_PUBLISHABLE_KEY

with the project's URL and publishable/anon key.

Do NOT put a Supabase service-role key in the browser.

## 4. Create GitHub repository

Create a repository, for example:

sales-crm

Upload:
- index.html
- schema.sql
- README.md
- .github/workflows/deploy.yml

## 5. Enable GitHub Pages

Repository → Settings → Pages → Build and deployment → Source → GitHub Actions.

Push to `main`.

GitHub Pages will deploy the site automatically.

The project-site URL normally follows:

https://YOUR-USERNAME.github.io/sales-crm/

## 6. Login

Agents use the email/password created in Supabase Authentication.

The manager uses the Auth account whose profile has role='manager'.

## Security

The app uses Supabase Auth and database Row Level Security. Agents are restricted to their own leads/sales. Manager accounts can access the team data.

For production, do not put secrets or a service-role key in the frontend.

## Current feature set

- Login
- Agent/manager roles
- Lead creation/editing
- Lead assignment
- Status pipeline
- Follow-up dates
- Sales conversion
- MRP / discount / discount %
- Final selling price
- Payment status/mode
- Team dashboard
- Sales dashboard
- Basic reports
- RLS policies

Next recommended additions:
- Excel/CSV bulk lead import
- Call disposition/activity timeline
- Discount approval workflow
- Attendance/activity tracking
- Manager target management
- Exportable reports
- Notifications/reminders
