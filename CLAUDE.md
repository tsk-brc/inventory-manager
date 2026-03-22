# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/rails server              # Start dev server on localhost:3000
bundle exec rspec             # Run all tests
bundle exec rspec spec/models # Run model specs only
bundle exec rspec spec/requests/products_spec.rb # Run single spec file
bundle exec rubocop           # Lint
bundle exec rubocop -A        # Lint with auto-correct
bin/rails db:setup            # Create DB + migrate + seed
bin/rails db:migrate          # Run pending migrations
```

## Architecture

Rails 8.1 monolith with PostgreSQL. Authentication via Devise. UI with Bootstrap 5 (CDN) + Hotwire.

### Domain Model

- **Product** — has many Inventories and StockMovements. Tracks SKU and minimum_quantity for low-stock alerts.
- **Warehouse** — has many Inventories and StockMovements.
- **Inventory** — join between Product and Warehouse with quantity. Composite unique index on [product_id, warehouse_id]. DB check constraint enforces quantity >= 0.
- **StockMovement** — records inbound/outbound operations. quantity must be > 0 (DB check constraint). Enum operation_type: inbound(0), outbound(1).

### Service Layer

**StockMovementService** is the only way to create stock movements. It wraps movement creation + inventory update in a single transaction. Outbound movements fail if inventory would go negative.

### Key Patterns

- Controllers use `params.expect()` (Rails 8 strong parameters)
- Status code `:unprocessable_content` (not `:unprocessable_entity` which is deprecated in Rack)
- RuboCop uses `plugins:` syntax (not `require:`)
- All controllers require authentication via `before_action :authenticate_user!` in ApplicationController
