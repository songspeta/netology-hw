CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE books_3 (
                       book_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       title VARCHAR(200) NOT NULL,
                       author VARCHAR(100) NOT NULL,
                       isbn VARCHAR(13) UNIQUE,
                       published_date DATE NOT NULL,
                       price DECIMAL(6,2),
                       CONSTRAINT published_date_check CHECK (published_date >= '2001-01-01')
);

-- Тестовые данные
INSERT INTO books_3 (title, author, isbn, published_date, price) VALUES
('The Da Vinci Code', 'Dan Brown', '9780307277298', '2003-03-18', 14.99),
('The Hunger Games', 'Suzanne Collins', '9780439023481', '2008-09-14', 11.99);