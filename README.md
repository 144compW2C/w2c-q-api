# 🚀 Rails API Template with Docker

## 📦 使用技術

-   **Ruby on Rails (API)**
-   **MySQL**
-   **Docker / Docker Compose**

---

## 📁 ディレクトリ構成

```
.
├── Dockerfile             # Rails用のDockerfile
├── compose.yml            # Docker Compose構成
├── .env                   # 環境変数
├── Gemfile                # Gem管理
├── Gemfile.lock
├── service/               # Railsアプリ本体（APIモードで生成）
├── db_data/               # MySQLの永続化ボリューム
└── README.md
```

---

## 🛠 セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/144compW2C/w2c-q-api.git
cd w2c-q-api
```

### 2. service ディレクトリ内で Rails API アプリを作成（初回のみ）

```bash
docker compose run web rails new . --api --database=mysql
```

### 3. Gem をインストール

```bash
docker compose run web bundle install
```

### 4. データベース設定の確認

`.env` または `config/database.yml` を編集して、`host: db` になっていることを確認。

### 5. DB 作成とマイグレーション

```bash
docker compose run web rails db:create
docker compose run web rails db:migrate
```

### 6. サーバ起動

```bash
docker compose up
```

---

## 🌐 アクセス

-   API エンドポイント: [http://localhost:3000](http://localhost:3000)
-   初期状態ではルートパスにアクセスすると Routing Error が出ますが、これは正常です（API のため HTML ルートが無いため）。

---

## 💬 備考

-   フロントエンド（Next.js など）と組み合わせて使用することを想定しています。
-   必要に応じて `CORS`, `Serializer`, `認証ライブラリ` を追加してください。
