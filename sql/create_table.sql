-- Active: 1762858863366@@127.0.0.1@5432@backend@public
-- Active: 1763821785462@@119.14.200.30@5432@backend@public0.30@5432@backend
-- 這份就是你用純 SQL 建表的腳本（PostgreSQL 版本）
-- 若已改名/改結構，請與你的 ORM 模型保持一致

CREATE TABLE IF NOT EXISTS users (
    id               SERIAL UNIQUE,
    email            VARCHAR(100) NOT NULL,
    username         VARCHAR(50) NOT NULL PRIMARY KEY,
    hashed_password  VARCHAR(255) NOT NULL,
    created_at       DATE DEFAULT CURRENT_TIMESTAMP
);
