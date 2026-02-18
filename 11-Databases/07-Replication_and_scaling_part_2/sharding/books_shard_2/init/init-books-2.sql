CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE books_2 (
                       book_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       title VARCHAR(200) NOT NULL,
                       author VARCHAR(100) NOT NULL,
                       isbn VARCHAR(13) UNIQUE,
                       published_date DATE NOT NULL,
                       price DECIMAL(6,2),
                       CONSTRAINT published_date_check CHECK (
                           published_date >= '1950-01-01' AND
                           published_date < '2001-01-01'
                           )
);

-- Тестовые данные
INSERT INTO books_2 (title, author, isbn, published_date, price) VALUES
('To Kill a Mockingbird', 'Harper Lee', '9780061120084', '1960-07-11', 12.99),
('The Catcher in the Rye', 'J.D. Salinger', '9780316769480', '1951-07-16', 10.99);