# OpenCode Configuration for consul-radstake

This file provides guidelines for agentic coding tools working in this repository.

## Commands

*   **Setup:** `bin/setup` (Run once initially)
*   **Run server:** `bin/rails s`
*   **Run all tests:** `bin/rspec`
*   **Run specific test file:** `bin/rspec path/to/your_spec.rb`
*   **Run linters (Ruby, JS, CSS):** `bundle exec pronto run` (Run before committing)
*   **Lint Ruby:** `bundle exec rubocop`
*   **Database seed:** `bin/rake db:dev_seed` (For development data)

## Code Style Guidelines

*   **Language:** Ruby on Rails 7.0, JavaScript (ES6+), SCSS.
*   **Formatting:** Follow `.rubocop.yml` rules (2 spaces indent, 110 char line limit, double quotes for strings). Use standard ESLint/Stylelint rules for JS/SCSS.
*   **Naming:** Standard Rails conventions (CamelCase classes/modules, snake_case methods/variables).
*   **Testing:** Use RSpec. Write specs for all new code/changes. Use FactoryBot for test data.
*   **Commits:** Follow [the seven rules of a great commit message](https://chris.beams.io/posts/git-commit/).
*   **Components:** Use ViewComponent for UI elements. Follow existing patterns in `app/components`.
*   **Internationalization (i18n):** Add/modify keys only in `config/locales/en.yml` and `config/locales/es.yml`.
*   **Error Handling:** Use standard Rails patterns. Be specific when rescuing exceptions.
*   **Dependencies:** Add new gems to `Gemfile` and run `bundle install`. Add JS packages via `npm` or `yarn` if a `package.json` exists (not explicitly found, check if needed).
*   **Database:** Use migrations for schema changes. Prefer `find_by` over `where.first`. Use `dependent` options for associations.
