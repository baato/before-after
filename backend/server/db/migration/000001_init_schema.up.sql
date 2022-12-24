CREATE TABLE "users" (
  "id" int PRIMARY KEY,
  "username" varchar UNIQUE NOT NULL,
  "role" int NOT NULL DEFAULT 0,
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "email_address" varchar,
  "is_email_verified" boolean DEFAULT false,
  "picture_url" varchar
);
