---
type: llm
---
PASS if the answer recommends a slow, salted password hash (ASP.NET Core Identity's
PasswordHasher, PBKDF2, bcrypt, scrypt or Argon2) and not a plain fast hash like SHA-256.

FAIL otherwise.
