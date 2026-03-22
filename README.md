# DecisionDesk

DecisionDesk is a Rails application for guided intake, branching screening, and administrator review. It walks an applicant through a conditional questionnaire, produces a recommendation, and stores submissions for searchable dashboard review.

## Stack

- Ruby on Rails
- ERB server-rendered pages
- JSON endpoints for the live screening interface
- A SQL database for application persistence, with a lightweight fallback available for local resilience

## Local Setup

From the project root:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

If you are not using the development Procfile flow, you can also run:

```bash
bin/rails server
```

## Main Screens

- `/` for the overview page
- `/app` for the interactive screening and dashboard experience
- `/api/health` for a basic health check

## What The App Demonstrates

- Branching eligibility-style screening
- Clear recommendation outcomes with readable decision paths
- Searchable administrator dashboard
- Resettable sample data for repeatable walkthroughs
- Rails controllers and service objects separated from the UI layer

## Testing

Run the test suite with:

```bash
bin/rails test
```
