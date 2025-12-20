INSERT INTO users (username, email, hashed_password)
VALUES (:username, :user_email, :user_hashed_password)
RETURNING user_id, username, email, created_at;