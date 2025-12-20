-- Active: 1762858863366@@127.0.0.1@5432@backend@public
-- 這份就是你用純 SQL 建表的腳本（PostgreSQL 版本）
-- 若已改名/改結構，請與你的 ORM 模型保持一致

CREATE TABLE IF NOT EXISTS users (
    user_id          SERIAL PRIMARY KEY,
    username         VARCHAR(50) NOT NULL UNIQUE,
    email            VARCHAR(100) NOT NULL,
    hashed_password  VARCHAR(255) NOT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 使用者設定（不含敏感資訊）
CREATE TABLE IF NOT EXISTS user_settings (
    username       VARCHAR(50) PRIMARY KEY,
    avatar_url     TEXT,
    display_name   TEXT,
    level          TEXT,
    daily_minutes  INTEGER,
    goal           TEXT,
    ui_lang        TEXT,
    push           BOOLEAN,
    newsletter     BOOLEAN,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
