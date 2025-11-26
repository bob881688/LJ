SELECT id, email, hashed_password, is_active
FROM users
WHERE email = :user_email
LIMIT 1;