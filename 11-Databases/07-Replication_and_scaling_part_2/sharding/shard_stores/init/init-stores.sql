CREATE TABLE stores (
                        store_id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        city VARCHAR(50) NOT NULL,
                        address VARCHAR(200),
                        phone VARCHAR(20)
);

-- Тестовые данные
INSERT INTO stores (name, city, address, phone) VALUES
('Central Bookstore', 'New York', '123 Main St', '+7-922-555-0100'),
('City Reads', 'Los Angeles', '456 Elm St', '+7-922-555-0200');