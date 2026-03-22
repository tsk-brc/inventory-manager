# Inventory Manager

A warehouse inventory management system built with Ruby on Rails.
Track products across multiple warehouses, record inbound/outbound stock movements, and monitor low-stock items in real time.

Built with service objects, DB-level constraints, transactional data integrity, and full test coverage.

## Features

- **Authentication** — Devise-based user authentication
- **Product Management** — CRUD with SKU tracking and minimum stock thresholds
- **Warehouse Management** — Multiple warehouse support
- **Stock Movements** — Inbound/outbound recording with transactional inventory updates
- **Dashboard** — Low-stock alerts and recent activity at a glance
- **Inventory View** — Per-warehouse stock visibility with status indicators

## Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Ruby 3.3 |
| Framework | Rails 8.1 |
| Database | PostgreSQL 14+ |
| Authentication | Devise |
| UI | Bootstrap 5, Hotwire (Turbo / Stimulus) |
| Pagination | Kaminari |
| Testing | RSpec, FactoryBot, Shoulda Matchers |
| Linting | RuboCop (rubocop-rails, rubocop-rspec) |
| Security | Brakeman, bundler-audit |
| CI | GitHub Actions |

## Getting Started

### Prerequisites

- Ruby 3.3.x ([rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/) recommended)
- PostgreSQL 14+ (running on localhost)
- Bundler (`gem install bundler`)

### Setup

```bash
git clone https://github.com/tsk-brc/inventory-manager.git
cd inventory-manager
bin/setup
```

`bin/setup` will install dependencies, create the database, run migrations, and load seed data.

Alternatively, if you prefer manual steps:

```bash
bundle install
bin/rails db:setup
```

### Start the server

```bash
bin/rails server
```

Open http://localhost:3000 and sign in with the seed account:

| | |
|---|---|
| Email | `admin@example.com` |
| Password | `password` |

> This account is created by `db/seeds.rb` for local development. The seed data includes sample products, warehouses, and stock movement history.

## Testing

```bash
bundle exec rspec                              # Run all tests
bundle exec rspec spec/models                  # Model specs
bundle exec rspec spec/requests                # Request specs
bundle exec rspec spec/services                # Service specs
bundle exec rspec spec/models/product_spec.rb  # Single file
```

## Linting

```bash
bundle exec rubocop       # Check
bundle exec rubocop -A    # Auto-correct
```

## Architecture

### Models

```
User
 └── has_many :stock_movements

Product
 ├── has_many :inventories
 ├── has_many :warehouses (through :inventories)
 └── has_many :stock_movements

Warehouse
 ├── has_many :inventories
 ├── has_many :products (through :inventories)
 └── has_many :stock_movements

Inventory (product × warehouse)
 ├── belongs_to :product
 └── belongs_to :warehouse
     unique index on [product_id, warehouse_id]

StockMovement
 ├── belongs_to :product
 ├── belongs_to :warehouse
 └── belongs_to :user
     enum operation_type: { inbound, outbound }
```

### Design Highlights

**Service layer for business logic**

Stock movement creation and inventory update are handled by `StockMovementService` within a single database transaction. The controller delegates to the service and never manipulates inventory directly, keeping the write path predictable and testable.

**Data integrity at the database level**

Application-level validations alone don't prevent race conditions or bypass scenarios. This project enforces constraints at the DB level as well:

- `CHECK (quantity >= 0)` on `inventories` — negative stock is impossible even under concurrent access
- `CHECK (quantity > 0)` on `stock_movements` — zero-quantity movements are rejected
- `UNIQUE (product_id, warehouse_id)` on `inventories` — one record per product-warehouse pair
- `NOT NULL` and foreign keys on all required columns

**Test structure**

61 examples across three layers, all passing:

- **Model specs** — associations, validations, scopes, and business logic (`Product.low_stock`, `#total_quantity`)
- **Service specs** — inbound/outbound inventory updates, insufficient stock rejection, invalid parameter handling
- **Request specs** — full CRUD lifecycle, authentication enforcement, error responses

**CI pipeline**

GitHub Actions runs RuboCop and Brakeman (static security analysis) in the lint job, and RSpec against a PostgreSQL service container in the test job. Both jobs must pass before merge.

## License

[MIT](LICENSE)
