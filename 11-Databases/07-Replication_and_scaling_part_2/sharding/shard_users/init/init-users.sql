CREATE TABLE users (
                       user_id SERIAL PRIMARY KEY,
                       email VARCHAR(100) UNIQUE NOT NULL,
                       first_name VARCHAR(50) NOT NULL,
                       last_name VARCHAR(50) NOT NULL,
                       city VARCHAR(50),
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Тестовые данные
INSERT INTO users (email, first_name, last_name, city) VALUES
('alice@example.com', 'Alice', 'Smith', 'New York'),
('bob@example.com', 'Bob', 'Johnson', 'Los Angeles');