CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE books_1 (
                       book_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       title VARCHAR(200) NOT NULL,
                       author VARCHAR(100) NOT NULL,
                       isbn VARCHAR(13) UNIQUE,
                       published_date DATE NOT NULL,
                       price DECIMAL(6,2),
                       CONSTRAINT published_date_check CHECK (published_date < '1950-01-01')
);

-- Тестовые данные
INSERT INTO books_1 (title, author, isbn, published_date, price) VALUES
('1984', 'George Orwell', '9780451524935', '1949-06-08', 9.99),
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', '1925-04-10', 8.99);