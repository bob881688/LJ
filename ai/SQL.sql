-- Active: 1763821376864@@119.14.200.30@5432@backend@public
-- Active: 1763821376864@@119.14.200.30@5432@backend
-- 建立句子的表
CREATE TABLE IF NOT EXISTS sentences (
    id SERIAL PRIMARY KEY, -- SERIAL是"自動"生成遞增的數字，可以理解成自動編號
    english_text TEXT NOT NULL, -- NOT NULL代表欄位不能是空的，TEXT可以儲存大量文字
    japanese_text TEXT NOT NULL,
    source TEXT DEFAULT 'unknown',
);

-- 建立學習紀錄表

CREATE TABLE IF NOT EXIST learning_history (
    id SERIAL PRIMARY KEY,
    sentence_id INTEGER NOT NULL,
    record TEXT NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)



--加索引讓找資料的速度變得更快
CREATE INDEX IF NOT EXISTS index_learning_history_sentence ON learning_history(sentence_id);
CREATE INDEX IF NOT EXISTS index_learning_history_action ON learning_history(action);
CREATE INDEX IF NOT EXISTS index_learning_history_time ON learning_history(create_time);


--建立跟文章與影片推薦有關的表
CREATE TABLE IF NOT EXIST resources (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    content TEXT NOT NULL,
    url TEXT NOT NULL,
);

CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INT,
    japanese TEXT NOT NULL,  -- 存日文
    meaning TEXT,            -- 存中文意思
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--建立練習場次表
CREATE TABLE IF NOT EXISTS quiz_history (
    id SERIAL PRIMARY KEY,
    user_id TEXT,
    score INTEGER,
    total_questions INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--建立練習詳細內容表
CREATE TABLE IF NOT EXISTS quiz_details (
    id SERIAL PRIMARY KEY,
    history_id INTEGER REFERENCES quiz_history(id),
    question TEXT,
    user_answer TEXT,
    correct_answer TEXT,
    is_correct BOOLEAN,
    options TEXT
);