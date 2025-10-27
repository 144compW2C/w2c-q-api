# W2C-Q-API 仕様書 v1

## 概要

W2C-Q-API は、Web 開発の学習用問題を管理するための REST API です。
ユーザーが問題を作成・解答し、その正誤判定を行う機能を提供します。

### 技術スタック

-   Ruby on Rails 7.1 (API mode)
-   MySQL 8.3
-   JWT 認証
-   Docker / Docker Compose

### ベース URL

```
http://localhost:3000
```

## 認証

この API は JWT (JSON Web Token) による認証を使用しています。

### 認証が必要なエンドポイント

一部のエンドポイントでは、リクエストヘッダーに認証トークンを含める必要があります。

```
Authorization: Bearer <token>
```

### 認証不要なエンドポイント

-   認証関連エンドポイント（ログイン、登録）
-   問題の閲覧エンドポイント（GET /problems）

---

## エンドポイント一覧

### 認証 (Auth)

-   [POST /auth/register](#post-authregister) - ユーザー登録
-   [POST /auth/login](#post-authlogin) - ログイン

### 問題 (Problems)

-   [GET /problems](#get-problems) - 問題一覧取得
-   [GET /problems/:id](#get-problemsid) - 問題詳細取得
-   [GET /problems/modelAnswers/:id](#get-problemsmodelanswersid) - 模範解答取得

### ストレージ (Storage)

-   [POST /storage/problems](#post-storageproblems) - 問題作成（要認証）
-   [POST /storage/answers](#post-storageanswers) - 解答送信

### リソース管理

-   [GET /tags](#get-tags) - タグ一覧取得
-   [GET /tags/:id](#get-tagsid) - タグ詳細取得
-   [GET /statuses](#get-statuses) - ステータス一覧取得
-   [GET /statuses/:id](#get-statusesid) - ステータス詳細取得
-   [GET /users](#get-users) - ユーザー一覧取得
-   [GET /users/:id](#get-usersid) - ユーザー詳細取得
-   [PUT /users/:id](#put-usersid) - ユーザー更新

---

## データモデル

### User（ユーザー）

| フィールド      | 型       | 必須 | 説明                                |
| --------------- | -------- | ---- | ----------------------------------- |
| id              | bigint   | ○    | ユーザー ID                         |
| name            | string   | ○    | ユーザー名                          |
| email           | string   | ○    | メールアドレス（一意）              |
| password_digest | string   | ○    | パスワードハッシュ                  |
| role            | string   | ○    | ロール（general / reviewer）        |
| class_name      | string   | -    | クラス名                            |
| delete_flag     | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at      | datetime | ○    | 作成日時                            |
| updated_at      | datetime | ○    | 更新日時                            |
| lock_version    | integer  | ○    | 楽観的ロック用バージョン            |

### Problem（問題）

| フィールド         | 型       | 必須 | 説明                                |
| ------------------ | -------- | ---- | ----------------------------------- |
| id                 | bigint   | ○    | 問題 ID                             |
| title              | text     | ○    | 問題タイトル                        |
| body               | text     | -    | 問題本文                            |
| tag_id             | bigint   | -    | タグ ID（外部キー）                 |
| status_id          | bigint   | -    | ステータス ID（外部キー）           |
| creator_id         | bigint   | ○    | 作成者 ID（外部キー）               |
| reviewer_id        | bigint   | -    | レビュアー ID（外部キー）           |
| level              | integer  | -    | レベル                              |
| difficulty         | integer  | -    | 難易度                              |
| is_multiple_choice | boolean  | -    | 選択式問題かどうか                  |
| model_answer       | text     | -    | 模範解答                            |
| reviewed_at        | datetime | -    | レビュー日時                        |
| delete_flag        | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at         | datetime | ○    | 作成日時                            |
| updated_at         | datetime | ○    | 更新日時                            |
| lock_version       | integer  | ○    | 楽観的ロック用バージョン            |

### Answer（解答）

| フィールド         | 型       | 必須 | 説明                                |
| ------------------ | -------- | ---- | ----------------------------------- |
| id                 | bigint   | ○    | 解答 ID                             |
| user_id            | bigint   | -    | ユーザー ID（外部キー）             |
| problem_id         | bigint   | -    | 問題 ID（外部キー）                 |
| selected_option_id | bigint   | -    | 選択肢 ID（外部キー）               |
| answer_text        | text     | -    | 解答テキスト                        |
| is_correct         | boolean  | ○    | 正解かどうか（デフォルト: false）   |
| delete_flag        | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at         | datetime | ○    | 作成日時                            |
| updated_at         | datetime | ○    | 更新日時                            |
| lock_version       | integer  | ○    | 楽観的ロック用バージョン            |

### Option（選択肢）

| フィールド   | 型       | 必須 | 説明                                |
| ------------ | -------- | ---- | ----------------------------------- |
| id           | bigint   | ○    | 選択肢 ID                           |
| problem_id   | bigint   | -    | 問題 ID（外部キー）                 |
| input_type   | text     | ○    | 入力タイプ                          |
| option_name  | text     | -    | 選択肢名（A, B, C...）              |
| content      | text     | -    | 選択肢の内容                        |
| delete_flag  | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at   | datetime | ○    | 作成日時                            |
| updated_at   | datetime | ○    | 更新日時                            |
| lock_version | integer  | ○    | 楽観的ロック用バージョン            |

### Tag（タグ）

| フィールド  | 型       | 必須 | 説明                                |
| ----------- | -------- | ---- | ----------------------------------- |
| id          | bigint   | ○    | タグ ID                             |
| tag_name    | text     | ○    | タグ名                              |
| delete_flag | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at  | datetime | ○    | 作成日時                            |
| updated_at  | datetime | ○    | 更新日時                            |

### Status（ステータス）

| フィールド  | 型       | 必須 | 説明                                |
| ----------- | -------- | ---- | ----------------------------------- |
| id          | bigint   | ○    | ステータス ID                       |
| status_name | text     | ○    | ステータス名                        |
| delete_flag | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at  | datetime | ○    | 作成日時                            |
| updated_at  | datetime | ○    | 更新日時                            |

#### ステータスの種類

-   下書き (draft)
-   承認待ち (pending)
-   公開中 (published)
-   返却 (returned)
-   却下 (rejected)

### ProblemAsset（問題アセット）

| フィールド   | 型       | 必須 | 説明                                |
| ------------ | -------- | ---- | ----------------------------------- |
| id           | bigint   | ○    | アセット ID                         |
| problem_id   | bigint   | ○    | 問題 ID（外部キー）                 |
| file_type    | string   | ○    | ファイルタイプ                      |
| file_name    | string   | -    | ファイル名                          |
| content_type | string   | -    | コンテンツタイプ                    |
| file_url     | text     | ○    | ファイル URL                        |
| context_type | text     | -    | コンテキストタイプ                  |
| delete_flag  | boolean  | ○    | 論理削除フラグ（デフォルト: false） |
| created_at   | datetime | ○    | 作成日時                            |
| updated_at   | datetime | ○    | 更新日時                            |
| lock_version | integer  | ○    | 楽観的ロック用バージョン            |

---

## API 詳細

### 認証 (Auth)

#### POST /auth/register

ユーザーを新規登録します。

**リクエスト**

```json
{
    "name": "山田太郎",
    "email": "yamada@example.com",
    "password": "Password123",
    "password_confirmation": "Password123",
    "role": "general",
    "class_name": "A1"
}
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| name | string | ○ | ユーザー名 |
| email | string | ○ | メールアドレス（一意） |
| password | string | ○ | パスワード（8 文字以上） |
| password_confirmation | string | ○ | パスワード確認 |
| role | string | ○ | ロール（general または reviewer） |
| class_name | string | - | クラス名 |

**レスポンス (201 Created)**

```json
{
    "name": "山田太郎",
    "email": "yamada@example.com"
}
```

**エラーレスポンス (422 Unprocessable Entity)**

```json
{
    "error": ["Email has already been taken"]
}
```

---

#### POST /auth/login

ログインして JWT トークンを取得します。

**リクエスト**

```json
{
    "email": "yamada@example.com",
    "password": "Password123"
}
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| email | string | ○ | メールアドレス |
| password | string | ○ | パスワード |

**レスポンス (200 OK)**

```json
{
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzA3NzE4MDB9..."
}
```

**エラーレスポンス (401 Unauthorized)**

```json
{
    "error": "メールアドレスまたはパスワードが違います"
}
```

---

### 問題 (Problems)

#### GET /problems

削除されていない問題の一覧を取得します。

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "title": "HTMLの基本構造",
        "body": "HTMLの基本的な構造を記述してください",
        "tag_id": 1,
        "status_id": 2,
        "creator_id": 1,
        "reviewer_id": null,
        "level": 1,
        "difficulty": 1,
        "is_multiple_choice": false,
        "model_answer": "<!DOCTYPE html>...",
        "reviewed_at": null,
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z",
        "lock_version": 0
    }
]
```

---

#### GET /problems/:id

指定された ID の問題詳細を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "title": "HTMLの基本構造",
    "body": "HTMLの基本的な構造を記述してください",
    "tag_id": 1,
    "status_id": 2,
    "creator_id": 1,
    "reviewer_id": null,
    "level": 1,
    "difficulty": 1,
    "is_multiple_choice": false,
    "model_answer": "<!DOCTYPE html>...",
    "reviewed_at": null,
    "delete_flag": false,
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z",
    "lock_version": 0
}
```

---

#### GET /problems/modelAnswers/:id

指定された問題の模範解答を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**レスポンス (200 OK) - 記述式の場合**

```json
{
    "problem_id": 1,
    "user_answer": "<!DOCTYPE html>..."
}
```

**レスポンス (200 OK) - 選択式の場合**

```json
{
    "problem_id": 2,
    "user_answer": "正解の選択肢の内容"
}
```

**エラーレスポンス (404 Not Found)**

```json
{
    "error": "Problem not found"
}
```

---

### ストレージ (Storage)

#### POST /storage/problems

新しい問題を作成します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

**リクエスト - 記述式問題の場合**

```json
{
    "title": "CSSのBox Model",
    "body": "CSSのBox Modelについて説明してください",
    "tags": "CSS",
    "status": "承認待ち",
    "level": 2,
    "difficulty": 3,
    "is_multiple_choice": false,
    "answer": "Box Modelは、margin, border, padding, contentで構成される"
}
```

**リクエスト - 選択式問題の場合**

```json
{
    "title": "JavaScriptのデータ型",
    "body": "JavaScriptのプリミティブ型でないものは？",
    "fk_tags": 3,
    "status": 1,
    "level": 1,
    "difficulty": 2,
    "is_multiple_choice": true,
    "options": ["String", "Number", "Object", "Boolean"],
    "answer": "Object"
}
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| title | string | ○ | 問題タイトル |
| body | text | - | 問題本文 |
| tags | string | - | タグ名（文字列） |
| fk_tags | integer | - | タグ ID（tags と排他） |
| status | string/integer | - | ステータス名または ID |
| level | integer | - | レベル |
| difficulty | integer | - | 難易度 |
| is_multiple_choice | boolean | - | 選択式問題かどうか |
| options | array | - | 選択肢の配列（is_multiple_choice: true の場合） |
| answer | string | ○ | 模範解答 |
| delete_flag | boolean | - | 論理削除フラグ（デフォルト: false） |

**レスポンス (201 Created)**

```json
{
    "id": 10
}
```

**エラーレスポンス (422 Unprocessable Entity)**

```json
{
    "error": "タグまたはステータスが見つかりません"
}
```

```json
{
    "error": "answer が options に含まれていません"
}
```

**エラーレスポンス (401 Unauthorized)**

```json
{
    "error": "認証エラー"
}
```

---

#### POST /storage/answers

問題に対する解答を送信し、正誤判定を受けます。

**リクエスト**

```json
{
    "fk_problems": 1,
    "fk_users": 5,
    "answer_text": "<!DOCTYPE html>..."
}
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| fk_problems | integer | ○ | 問題 ID |
| fk_users | integer | ○ | ユーザー ID |
| answer_text | string | ○ | 解答テキスト |

**レスポンス (201 Created)**

```json
{
    "is_correct": true
}
```

**正誤判定ロジック**

-   **選択式問題**: `answer_text`が問題の選択肢(`options`の content)のいずれかと一致するか
-   **記述式問題**: `answer_text`が問題の`model_answer`と完全一致するか（前後の空白は除く）

**エラーレスポンス (422 Unprocessable Entity)**

```json
{
    "error": ["Problem must exist"]
}
```

---

### リソース管理

#### GET /tags

タグ一覧を取得します。

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "tag_name": "HTML",
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
    },
    {
        "id": 2,
        "tag_name": "CSS",
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
    }
]
```

---

#### GET /tags/:id

指定された ID のタグ詳細を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | タグ ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "tag_name": "HTML",
    "delete_flag": false,
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z"
}
```

---

#### GET /statuses

ステータス一覧を取得します。

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "status_name": "下書き",
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
    },
    {
        "id": 2,
        "status_name": "承認待ち",
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
    }
]
```

---

#### GET /statuses/:id

指定された ID のステータス詳細を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | ステータス ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "status_name": "下書き",
    "delete_flag": false,
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z"
}
```

---

#### GET /users

ユーザー一覧を取得します。

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "name": "管理者 太郎",
        "email": "admin@example.com",
        "role": "reviewer",
        "class_name": "T1",
        "delete_flag": false,
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z",
        "lock_version": 0
    }
]
```

---

#### GET /users/:id

指定された ID のユーザー詳細を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | ユーザー ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "name": "管理者 太郎",
    "email": "admin@example.com",
    "role": "reviewer",
    "class_name": "T1",
    "delete_flag": false,
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z",
    "lock_version": 0
}
```

---

#### PUT /users/:id

指定された ID のユーザー情報を更新します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | ユーザー ID（URL パス） |

**リクエスト**

```json
{
    "name": "管理者 次郎",
    "class_name": "T2"
}
```

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "name": "管理者 次郎",
    "email": "admin@example.com",
    "role": "reviewer",
    "class_name": "T2",
    "delete_flag": false,
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z",
    "lock_version": 0
}
```

---

## エラーレスポンス

### 共通エラーコード

| HTTP ステータス | 説明                                        |
| --------------- | ------------------------------------------- |
| 200             | OK - リクエスト成功                         |
| 201             | Created - リソース作成成功                  |
| 401             | Unauthorized - 認証エラー                   |
| 404             | Not Found - リソースが見つからない          |
| 422             | Unprocessable Entity - バリデーションエラー |
| 500             | Internal Server Error - サーバー内部エラー  |

### エラーレスポンス形式

```json
{
    "error": "エラーメッセージ"
}
```

または

```json
{
    "error": ["エラーメッセージ1", "エラーメッセージ2"]
}
```

---

## 認証フロー

1. **ユーザー登録**: `POST /auth/register` でユーザーを作成
2. **ログイン**: `POST /auth/login` で JWT トークンを取得
3. **認証が必要なリクエスト**: リクエストヘッダーに `Authorization: Bearer <token>` を含める

### JWT トークンの有効期限

デフォルトで 24 時間（1 日）です。

---

## 論理削除について

この API では、ほとんどのリソースで論理削除（ソフトデリート）を採用しています。
`delete_flag` が `true` のレコードは削除済みとして扱われ、通常のクエリでは取得されません。

---

## 楽観的ロック

一部のテーブルでは `lock_version` カラムを使用した楽観的ロック制御が実装されています。
これにより、同時更新時の競合を検出できます。

---

## 開発環境セットアップ

詳細は [README.md](../../../README.md) を参照してください。

```bash
# リポジトリのクローン
git clone https://github.com/144compW2C/w2c-q-api.git
cd w2c-q-api

# Dockerコンテナの起動
docker compose up

# データベースの作成とマイグレーション
docker compose run web rails db:create
docker compose run web rails db:migrate

# シードデータの投入
docker compose run web rails db:seed
```

---

## ライセンス

このプロジェクトのライセンス情報については、リポジトリを確認してください。
