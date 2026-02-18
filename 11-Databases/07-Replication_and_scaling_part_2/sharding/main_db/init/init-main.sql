-- 1. Включаем расширение
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Регистрируем серверы
CREATE SERVER users_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'users_shard', dbname 'users_db', port '5432');

CREATE SERVER stores_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'stores_shard', dbname 'stores_db', port '5432');

CREATE SERVER books_1_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'books_shard_1', dbname 'books_db', port '5432');

CREATE SERVER books_2_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'books_shard_2', dbname 'books_db', port '5432');

CREATE SERVER books_3_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'books_shard_3', dbname 'books_db', port '5432');

-- 3. Настройка подключений
CREATE USER MAPPING FOR postgres SERVER users_server OPTIONS (user 'postgres');
CREATE USER MAPPING FOR postgres SERVER stores_server OPTIONS (user 'postgres');
CREATE USER MAPPING FOR postgres SERVER books_1_server OPTIONS (user 'postgres');
CREATE USER MAPPING FOR postgres SERVER books_2_server OPTIONS (user 'postgres');
CREATE USER MAPPING FOR postgres SERVER books_3_server OPTIONS (user 'postgres');

-- 4. Импортируем внешние таблицы
-- ВАЖНО: Сначала убедитесь, что на шардах таблицы существуют в схеме public
-- и имеют правильные имена (users, stores)
IMPORT FOREIGN SCHEMA public FROM SERVER users_server INTO public OPTIONS (import_default 'false');
IMPORT FOREIGN SCHEMA public FROM SERVER stores_server INTO public OPTIONS (import_default 'false');
IMPORT FOREIGN SCHEMA public FROM SERVER books_1_server INTO public OPTIONS (import_default 'false');
IMPORT FOREIGN SCHEMA public FROM SERVER books_2_server INTO public OPTIONS (import_default 'false');
IMPORT FOREIGN SCHEMA public FROM SERVER books_3_server INTO public OPTIONS (import_default 'false');



-- 5. Объединенное представление для книг (UNION ALL)
CREATE VIEW books_view AS
SELECT * FROM books_1
UNION ALL
SELECT * FROM books_2
UNION ALL
SELECT * FROM books_3;

-- 6. Правила для вставки
CREATE RULE books_insert_1 AS ON INSERT TO books_view
  WHERE NEW.published_date < '1950-01-01'
  DO INSTEAD
    INSERT INTO books_1 (book_id, title, author, isbn, published_date, price)
    VALUES (NEW.book_id, NEW.title, NEW.author, NEW.isbn, NEW.published_date, NEW.price);

CREATE RULE books_insert_2 AS ON INSERT TO books_view
  WHERE NEW.published_date >= '1950-01-01' AND NEW.published_date < '2001-01-01'
  DO INSTEAD
    INSERT INTO books_2 (book_id, title, author, isbn, published_date, price)
    VALUES (NEW.book_id, NEW.title, NEW.author, NEW.isbn, NEW.published_date, NEW.price);

CREATE RULE books_insert_3 AS ON INSERT TO books_view
  WHERE NEW.published_date >= '2001-01-01'
  DO INSTEAD
    INSERT INTO books_3 (book_id, title, author, isbn, published_date, price)
    VALUES (NEW.book_id, NEW.title, NEW.author, NEW.isbn, NEW.published_date, NEW.price);

-- UPDATE для книг до 1950 года
CREATE RULE books_update_1 AS ON UPDATE TO books_view
                                 WHERE OLD.published_date < '1950-01-01'
                                     DO INSTEAD
UPDATE books_1 SET
                   title = NEW.title,
                   author = NEW.author,
                   isbn = NEW.isbn,
                   published_date = NEW.published_date,
                   price = NEW.price
WHERE book_id = OLD.book_id;

-- UPDATE для книг 1950-2000
CREATE RULE books_update_2 AS ON UPDATE TO books_view
                                 WHERE OLD.published_date >= '1950-01-01' AND OLD.published_date < '2001-01-01'
                                     DO INSTEAD
UPDATE books_2 SET
                   title = NEW.title,
                   author = NEW.author,
                   isbn = NEW.isbn,
                   published_date = NEW.published_date,
                   price = NEW.price
WHERE book_id = OLD.book_id;

-- UPDATE для книг после 2000 года
CREATE RULE books_update_3 AS ON UPDATE TO books_view
                                 WHERE OLD.published_date >= '2001-01-01'
                                     DO INSTEAD
UPDATE books_3 SET
                   title = NEW.title,
                   author = NEW.author,
                   isbn = NEW.isbn,
                   published_date = NEW.published_date,
                   price = NEW.price
WHERE book_id = OLD.book_id;

-- DELETE для книг до 1950 года
CREATE RULE books_delete_1 AS ON DELETE TO books_view
  WHERE OLD.published_date < '1950-01-01'
  DO INSTEAD
DELETE FROM books_1 WHERE book_id = OLD.book_id;

-- DELETE для книг 1950-2000
CREATE RULE books_delete_2 AS ON DELETE TO books_view
  WHERE OLD.published_date >= '1950-01-01' AND OLD.published_date < '2001-01-01'
  DO INSTEAD
DELETE FROM books_2 WHERE book_id = OLD.book_id;

-- DELETE для книг после 2000 года
CREATE RULE books_delete_3 AS ON DELETE TO books_view
  WHERE OLD.published_date >= '2001-01-01'
  DO INSTEAD
DELETE FROM books_3 WHERE book_id = OLD.book_id;