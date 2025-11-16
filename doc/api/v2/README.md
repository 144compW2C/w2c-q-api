# W2C-Q-API 仕様書 v2

## 概要

W2C-Q-API v2 は、Web 開発の学習用問題を管理するための REST API の拡張版です。
ユーザーが問題を作成・解答し、管理者が問題を承認・管理する機能を提供します。

### 技術スタック

-   Ruby on Rails 7.1 (API mode)
-   MySQL 8.3
-   JWT 認証
-   Docker / Docker Compose

### ベース URL

```
http://localhost:3000
```

### v2 の新機能・変更点

-   管理者用 API の追加（Admin namespace）
-   問題承認ワークフローの実装
-   楽観的ロック（lock_version）によるデータ整合性保証
-   権限管理の強化（reviewer / admin / general）
-   問題の選択肢管理機能
-   ユーザー作成問題一覧機能
-   より詳細なエラーハンドリング

---

## 認証・認可

### 認証方式

JWT (JSON Web Token) による認証を使用。

### ユーザーロール

| ロール   | 説明               | 権限                               |
| -------- | ------------------ | ---------------------------------- |
| general  | 一般ユーザー       | 問題閲覧、解答投稿                 |
| reviewer | 管理者・レビュアー | 問題作成・編集・承認、ユーザー管理 |
| admin    | システム管理者     | 全権限                             |

### 認証ヘッダー

```
Authorization: Bearer <token>
```

---

## エンドポイント一覧

### 認証 (Auth)

-   [POST /auth/register](#post-authregister) - ユーザー登録
-   [POST /auth/login](#post-authlogin) - ログイン

### 問題管理 (Problems)

-   [GET /problems](#get-problems) - 問題一覧取得
-   [GET /problems/:id](#get-problemsid) - 問題詳細取得
-   [GET /problems/modelAnswers/:id](#get-problemsmodelanswersid) - 模範解答取得
-   [GET /createProblem/:id](#get-createproblemid) - ユーザー作成問題一覧
-   [GET /options/:id](#get-optionsid) - 問題の選択肢取得

### ストレージ (Storage)

-   [GET /storage/problems](#get-storageproblems) - 問題一覧（詳細情報付き）
-   [POST /storage/problems](#post-storageproblems) - 問題作成（要認証・管理者権限）
-   [PUT /storage/problems/:id](#put-storageproblemsid) - 問題更新（要認証・管理者権限）
-   [POST /storage/answers](#post-storageanswers) - 解答投稿

### 管理者 API (Admin)

-   [GET /admin/problems](#get-adminproblems) - 承認待ち問題一覧（要管理者権限）
-   [GET /admin/problems/:id](#get-adminproblemsid) - 問題詳細（要管理者権限）
-   [POST /admin/problems/:id/approve](#post-adminproblemsidapprove) - 問題承認（要管理者権限）
-   [PUT /admin/problems/:id/organize](#put-adminproblemsidorganize) - 問題整理（要管理者権限）
-   [DELETE /admin/problems/:id](#delete-adminproblemsid) - 問題削除（要管理者権限）

### リソース管理

-   [GET /tags](#get-tags) - タグ一覧取得（要認証）
-   [GET /tags/:id](#get-tagsid) - タグ詳細取得（要認証）
-   [GET /status](#get-status) - ステータス一覧取得（エイリアス）（要認証）
-   [GET /status/:id](#get-statusid) - ステータス詳細取得（エイリアス）（要認証）
-   [GET /users](#get-users) - ユーザー一覧取得（要認証）
-   [GET /users/:id](#get-usersid) - ユーザー詳細取得（要認証）
-   [PUT /users/:id](#put-usersid) - ユーザー更新（要管理者権限）

---

## データモデル

v1 と同様の基本構造に加えて、以下の拡張が行われています：

### 楽観的ロック

`lock_version`フィールドによる楽観的ロック制御を実装。

### ソフトデリート

`delete_flag`による論理削除を全テーブルで実装。

### 問題ステータス管理

問題は以下のステータスで管理されます：

-   **下書き** - 作成中
-   **承認待ち** - 管理者の承認待ち
-   **公開中** - 承認済み・公開中
-   **返却** - 修正が必要
-   **却下** - 承認されず

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

**レスポンス (200 OK)**

```json
{
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzA3NzE4MDB9..."
}
```

---

### 問題管理 (Problems)

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

---

#### GET /createProblem/:id

指定されたユーザーが作成した問題の一覧を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | ユーザー ID（URL パス） |

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "title": "HTMLの基本構造",
        "tags": "HTML",
        "status": "公開中",
        "level": 1,
        "difficulty": 1,
        "creator_id": 1
    }
]
```

**レスポンス (200 OK) - 問題がない場合**

```json
{
    "message": "作成された問題はありません"
}
```

---

#### GET /options/:id

指定された問題の選択肢を取得します。

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "problem_id": 1,
        "option_name": "A",
        "content": "String",
        "input_type": "choice"
    },
    {
        "id": 2,
        "problem_id": 1,
        "option_name": "B",
        "content": "Number",
        "input_type": "choice"
    }
]
```

---

### ストレージ (Storage)

#### GET /storage/problems

問題一覧を関連データ付きで取得します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "title": "HTMLの基本構造",
        "level": 1,
        "difficulty": 1,
        "is_multiple_choice": false,
        "model_answer": "<!DOCTYPE html>...",
        "tag": {
            "id": 1,
            "tag_name": "HTML"
        },
        "status": {
            "id": 2,
            "status_name": "公開中"
        }
    }
]
```

---

#### POST /storage/problems

新しい問題を作成します。（要認証・管理者権限）

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
    "error": ["タグまたはステータスが見つかりません"]
}
```

**エラーレスポンス (403 Forbidden)**

```json
{
    "error": "権限がありません（管理者のみ実行可能です）"
}
```

---

#### PUT /storage/problems/:id

既存の問題を更新します。（要認証・管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |
| lock_version | integer | ○ | 楽観的ロック用バージョン |

**リクエスト**

```json
{
    "title": "更新されたタイトル",
    "body": "更新された本文",
    "level": 3,
    "lock_version": 1
}
```

**レスポンス (200 OK)**

```json
{
    "id": 1
}
```

**エラーレスポンス (409 Conflict) - 楽観的ロック**

```json
{
    "error": "他のユーザーによって更新されました。画面を再読み込みしてからやり直してください。"
}
```

---

### 管理者 API (Admin)

#### GET /admin/problems

承認待ちの問題一覧を取得します。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "title": "HTMLの基本構造",
        "tags": "HTML",
        "status": "承認待ち",
        "level": 1,
        "difficulty": 1,
        "creator_id": 1
    }
]
```

**レスポンス (200 OK) - 承認待ち問題がない場合**

```json
{
    "message": "承認待ちの問題はありません"
}
```

**エラーレスポンス (403 Forbidden)**

```json
{
    "error": "権限がありません（管理者のみ）"
}
```

---

#### GET /admin/problems/:id

問題の詳細情報を取得します。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

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
    "tags": "HTML",
    "status": "承認待ち",
    "level": 1,
    "difficulty": 1,
    "creator_id": 1,
    "reviewer_id": null,
    "is_multiple_choice": true,
    "options": [
        {
            "id": 1,
            "option_name": "A",
            "content": "String",
            "input_type": "choice"
        },
        {
            "id": 2,
            "option_name": "B",
            "content": "Number",
            "input_type": "choice"
        }
    ],
    "model_answer": "Object",
    "created_at": "2025-01-01T00:00:00.000Z",
    "updated_at": "2025-01-01T00:00:00.000Z",
    "reviewed_at": null,
    "delete_flag": false
}
```

---

#### POST /admin/problems/:id/approve

問題を承認して公開状態にします。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "status": "公開中"
}
```

**処理内容**

-   問題のステータスを「公開中」に変更
-   `reviewer_id`に現在のユーザー ID を設定
-   `reviewed_at`に現在時刻を設定

**エラーレスポンス (422 Unprocessable Entity)**

```json
{
    "error": "ステータス「公開中」が存在しません"
}
```

---

#### PUT /admin/problems/:id/organize

問題のタグ、ステータス、レベル、難易度を整理・変更します。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**リクエスト**

```json
{
    "tags": "JavaScript",
    "status": "公開中",
    "level": 2,
    "difficulty": 3
}
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| tags | string | - | タグ名 |
| status | string/integer | - | ステータス名または ID |
| level | integer | - | レベル |
| difficulty | integer | - | 難易度 |

**レスポンス (200 OK)**

```json
{
    "id": 1
}
```

**エラーレスポンス (422 Unprocessable Entity)**

```json
{
    "error": "指定されたタグが見つかりません"
}
```

---

#### DELETE /admin/problems/:id

問題とその関連データを論理削除します。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | 問題 ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "success": true
}
```

**処理内容**

-   問題の`delete_flag`を true に設定
-   関連する選択肢（options）を論理削除
-   関連するアセット（problem_assets）を論理削除
-   関連する解答（answers）を論理削除

---

### リソース管理

#### GET /tags

タグ一覧を取得します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "tag_name": "HTML"
    },
    {
        "id": 2,
        "tag_name": "CSS"
    }
]
```

---

#### GET /tags/:id

指定された ID のタグ詳細を取得します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | タグ ID（URL パス） |

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "tag_name": "HTML"
}
```

---

#### GET /status

`GET /statuses`のエイリアス。ステータス一覧を取得します。（要認証）

#### GET /status/:id

`GET /statuses/:id`のエイリアス。ステータス詳細を取得します。（要認証）

---

#### GET /users

ユーザー一覧を取得します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

**レスポンス (200 OK)**

```json
[
    {
        "id": 1,
        "name": "管理者 太郎",
        "email": "admin@example.com",
        "role": "reviewer",
        "class_name": "T1"
    }
]
```

---

#### GET /users/:id

指定された ID のユーザー詳細を取得します。（要認証）

**ヘッダー**

```
Authorization: Bearer <token>
```

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
    "class_name": "T1"
}
```

---

#### PUT /users/:id

指定された ID のユーザー情報を更新します。（要管理者権限）

**ヘッダー**

```
Authorization: Bearer <token>
```

**パラメータ**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | integer | ○ | ユーザー ID（URL パス） |
| lock_version | integer | ○ | 楽観的ロック用バージョン |

**リクエスト**

```json
{
    "name": "管理者 次郎",
    "role": "admin",
    "class_name": "T2",
    "lock_version": 0
}
```

**レスポンス (200 OK)**

```json
{
    "id": 1,
    "name": "管理者 次郎",
    "email": "admin@example.com",
    "role": "admin",
    "class_name": "T2"
}
```

**エラーレスポンス (409 Conflict) - 楽観的ロック**

```json
{
    "error": "Conflict: lock_version mismatch"
}
```

**エラーレスポンス (403 Forbidden)**

```json
{
    "error": "Forbidden: admin only"
}
```

---

### 解答投稿

#### POST /storage/answers

問題に対する解答を投稿し、正誤判定を受けます。

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

---

## エラーレスポンス

### 共通エラーコード

| HTTP ステータス | 説明                                        |
| --------------- | ------------------------------------------- |
| 200             | OK - リクエスト成功                         |
| 201             | Created - リソース作成成功                  |
| 401             | Unauthorized - 認証エラー                   |
| 403             | Forbidden - 権限エラー                      |
| 404             | Not Found - リソースが見つからない          |
| 409             | Conflict - 楽観的ロック競合                 |
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

## 問題承認ワークフロー

### 問題作成から公開までの流れ

1. **問題作成** (`POST /storage/problems`)

    - 管理者権限のユーザーが問題を作成
    - 初期ステータスは「承認待ち」

2. **管理者による承認** (`GET /admin/problems`, `GET /admin/problems/:id`)

    - 管理者が承認待ち問題を確認
    - 必要に応じて問題の整理（`PUT /admin/problems/:id/organize`）

3. **問題承認** (`POST /admin/problems/:id/approve`)

    - 問題を「公開中」ステータスに変更
    - レビュアー ID、レビュー日時を記録

4. **問題削除** (`DELETE /admin/problems/:id`)
    - 必要に応じて問題を論理削除

### ステータス管理

| ステータス | 説明             | アクション                   |
| ---------- | ---------------- | ---------------------------- |
| 下書き     | 作成中の問題     | 編集可能                     |
| 承認待ち   | 管理者の承認待ち | 管理者による確認・承認       |
| 公開中     | 承認済み・公開中 | 一般ユーザーが閲覧・解答可能 |
| 返却       | 修正が必要       | 作成者による修正             |
| 却下       | 承認されず       | 問題として不適切             |

---

## セキュリティ・整合性

### 楽観的ロック

データの整合性を保つため、以下のエンドポイントで楽観的ロックを実装：

-   `PUT /storage/problems/:id`
-   `PUT /users/:id`

### 権限管理

#### 管理者権限が必要な API

-   `POST /storage/problems`
-   `PUT /storage/problems/:id`
-   `PUT /users/:id`
-   `/admin/*` - 全ての管理者 API エンドポイント

#### 認証が必要だが権限制限のない API

-   `GET /tags`, `GET /tags/:id`
-   `GET /statuses`, `GET /statuses/:id`
-   `GET /users`, `GET /users/:id`
-   `GET /storage/problems`

#### 認証不要の API

-   `POST /auth/register`, `POST /auth/login`
-   `GET /problems`, `GET /problems/:id`
-   `GET /problems/modelAnswers/:id`
-   `GET /createProblem/:id`
-   `GET /options/:id`
-   `POST /storage/answers`

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

## v1 からの移行

### 新しく追加されたエンドポイント

-   管理者 API (`/admin/*`)
-   問題の選択肢取得 (`GET /options/:id`)
-   ユーザー作成問題一覧 (`GET /createProblem/:id`)
-   詳細付き問題一覧 (`GET /storage/problems`)
-   問題更新 (`PUT /storage/problems/:id`)

### 変更された機能

-   認証が必要になったエンドポイント（tags, statuses, users）
-   権限管理の強化
-   楽観的ロックの実装
-   より詳細なエラーハンドリング

### 非互換性の変更

-   一部のエンドポイントで認証が必須になりました
-   エラーレスポンスの形式が一部変更されました

---

## ライセンス

このプロジェクトのライセンス情報については、リポジトリを確認してください。
