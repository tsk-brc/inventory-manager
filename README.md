# Inventory Manager

Ruby on Rails で構築した倉庫在庫管理システムです。
複数倉庫にまたがる商品の在庫を管理し、入出庫の記録と在庫数の自動更新を行います。

サービス層でのトランザクション管理、DB レベルの整合性制約、RSpec によるテスト整備を意識して実装しています。

## 機能

- **認証** — Devise によるユーザー認証
- **商品管理** — SKU・最低在庫数つきの CRUD
- **倉庫管理** — 複数倉庫の登録・管理
- **入出庫記録** — 入庫・出庫の記録とトランザクションによる在庫更新
- **ダッシュボード** — 低在庫アラートと直近の入出庫履歴
- **在庫一覧** — 倉庫別の在庫状況とステータス表示

## 技術スタック

| 分類 | 技術 |
|------|------|
| 言語 | Ruby 3.3 |
| フレームワーク | Rails 8.1 |
| データベース | PostgreSQL 14+ |
| 認証 | Devise |
| UI | Bootstrap 5, Hotwire (Turbo / Stimulus) |
| ページネーション | Kaminari |
| テスト | RSpec, FactoryBot, Shoulda Matchers |
| 静的解析 | RuboCop (rubocop-rails, rubocop-rspec) |
| セキュリティ | Brakeman, bundler-audit |
| CI | GitHub Actions |

## セットアップ

### 前提条件

- Ruby 3.3.x（[rbenv](https://github.com/rbenv/rbenv) または [asdf](https://asdf-vm.com/) を推奨）
- PostgreSQL 14+（localhost で起動済み）
- Bundler（`gem install bundler`）

### インストール

```bash
git clone https://github.com/tsk-brc/inventory-manager.git
cd inventory-manager
bin/setup
```

`bin/setup` で依存関係のインストール、DB 作成、マイグレーション、seed データの投入まで完了します。

手動で実行する場合:

```bash
bundle install
bin/rails db:setup
```

### サーバー起動

```bash
bin/rails server
```

http://localhost:3000 を開き、seed アカウントでログインできます。

| | |
|---|---|
| Email | `admin@example.com` |
| Password | `password` |

> このアカウントは `db/seeds.rb` で作成されるローカル開発用のデータです。商品・倉庫・入出庫履歴のサンプルデータも含まれています。

## テスト

```bash
bundle exec rspec                              # 全テスト実行
bundle exec rspec spec/models                  # モデルスペック
bundle exec rspec spec/requests                # リクエストスペック
bundle exec rspec spec/services                # サービススペック
bundle exec rspec spec/models/product_spec.rb  # ファイル単位で実行
```

## 静的解析

```bash
bundle exec rubocop       # チェック
bundle exec rubocop -A    # 自動修正
```

## アーキテクチャ

### モデル構成

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

Inventory（商品 × 倉庫）
 ├── belongs_to :product
 └── belongs_to :warehouse
     unique index on [product_id, warehouse_id]

StockMovement
 ├── belongs_to :product
 ├── belongs_to :warehouse
 └── belongs_to :user
     enum operation_type: { inbound, outbound }
```

### 設計上のポイント

**サービス層によるビジネスロジックの分離**

入出庫の記録と在庫数の更新は `StockMovementService` が単一のトランザクション内で処理します。コントローラは在庫を直接操作せず、書き込み経路をサービスに集約することでテストしやすい構成にしています。

**DB レベルでのデータ整合性**

アプリケーションのバリデーションだけでは、並行アクセスやバリデーション迂回時にデータ不整合が起きる可能性があります。このプロジェクトでは DB レベルでも制約を設けています。

- `inventories` に `CHECK (quantity >= 0)` を設定 — 在庫数がマイナスになることを防止
- `stock_movements` に `CHECK (quantity > 0)` を設定 — 数量ゼロの入出庫を拒否
- `inventories` に `UNIQUE (product_id, warehouse_id)` を設定 — 商品と倉庫の組み合わせの重複を防止
- 必須カラムに `NOT NULL` と外部キー制約を設定

**テスト構成**

モデル・サービス・リクエストの 3 層で構成しています。

- **モデルスペック** — アソシエーション、バリデーション、スコープ、ビジネスロジック（`Product.low_stock`, `#total_quantity`）
- **サービススペック** — 入庫・出庫による在庫更新、在庫不足時の拒否、不正パラメータの処理
- **リクエストスペック** — CRUD の一連のライフサイクル、認証の強制、エラーレスポンス

**CI**

GitHub Actions で 2 ジョブを実行しています。lint ジョブで RuboCop と Brakeman（静的セキュリティ解析）を、test ジョブで PostgreSQL サービスコンテナに対して RSpec を実行します。

## ライセンス

[MIT](LICENSE)
