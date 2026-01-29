-- ========================================
-- 1. Создание таблиц
-- ========================================

-- Типы подразделений
CREATE TABLE unit_types (
    unit_type_id SERIAL PRIMARY KEY,
    unit_type_name VARCHAR(50) NOT NULL UNIQUE
);

-- Должности
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(200) NOT NULL UNIQUE
);

-- Адреса филиалов
CREATE TABLE branch_addresses (
    branch_address_id SERIAL PRIMARY KEY,
    region VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    street VARCHAR(200),
    building VARCHAR(20),
    full_address TEXT NOT NULL UNIQUE
);

-- Структурные подразделения
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(200) NOT NULL UNIQUE,
    unit_type_id INTEGER NOT NULL REFERENCES unit_types(unit_type_id) ON DELETE RESTRICT
);

-- Проекты
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL UNIQUE
);

-- Сотрудники
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    salary NUMERIC(10, 2) NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL,
    position_id INTEGER NOT NULL REFERENCES positions(position_id) ON DELETE RESTRICT,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    branch_address_id INTEGER NOT NULL REFERENCES branch_addresses(branch_address_id) ON DELETE RESTRICT
);

-- Связь сотрудников с проектами (многие-ко-многим)
CREATE TABLE employee_projects (
    employee_project_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    project_id INTEGER NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    CONSTRAINT unique_employee_project UNIQUE (employee_id, project_id)
);

-- ========================================
-- 2. Заполнение справочников
-- ========================================

-- Типы подразделений
INSERT INTO unit_types (unit_type_name) VALUES 
    ('Департамент'),
    ('Отдел'),
    ('Группа');

-- Должности (уникальные из файла)
INSERT INTO positions (position_name) VALUES 
    ('ведущий архектор'),
    ('ведущий инженер'),
    ('ведущий разработчик'),
    ('ведущий QA инженер'),
    ('инженер'),
    ('руководель направления разработки'),
    ('руководель проектов'),
    ('руководель проектов по интеграции'),
    ('руководель сервисных проектов'),
    ('разработчик'),
    ('специалист'),
    ('специалист по персоналу'),
    ('старший архектор'),
    ('старший инженер'),
    ('старший разработчик');

-- Адреса филиалов (уникальные из файла)
INSERT INTO branch_addresses (region, city, street, building, full_address) VALUES 
    ('Приморский край', 'Владивосток', 'ул Нижнепортовая', '1', 'Приморский край, г. Владивосток, ул Нижнепортовая, д. 1'),
    ('Краснодарский край', 'Краснодар', 'ул Путевая', '1', 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
    ('Ростовская обл', 'Ростов-на-Дону', 'ул 2-я Краснодарская', '135/2', 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2');

-- Структурные подразделения
INSERT INTO departments (department_name, unit_type_id) VALUES 
    ('Центр компетенций QA Москва', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Отдел')),
    ('Группа сервисной поддержки', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Центр разработки продуктов для digital-маркетинга', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Отдел')),
    ('Департамент Техническая поддержка', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Департамент')),
    ('Группа CRM 2', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Группа первичной диагностики №2', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Группа Billing', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Группа DOC', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Группа ODS', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Группа Rating', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Центр управления сервисами', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Отдел')),
    ('Департамент FBF', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Департамент')),
    ('Центр анализа и архектуры Medio', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Отдел')),
    ('Центр разработки Medio', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Отдел')),
    ('Группа инфраструктуры', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Группа')),
    ('Департамент Rating and Charging', (SELECT unit_type_id FROM unit_types WHERE unit_type_name = 'Департамент'));

-- Проекты (все уникальные из файла)
INSERT INTO projects (project_name) VALUES 
    ('Итэлма Инженерный корпус'),
    ('Севастополь ТВ'),
    ('Кристалл Доп объем'),
    ('Ростелеком. Гончарная,ВТБ Башня PM'),
    ('Газпромбанк Бирюзова'),
    ('Гпб Оазис Кабинет З.'),
    ('Комплекс Pine Creek Доп работы'),
    ('Сбербанк Нижний Новгород'),
    ('Рособоронэкспорт _ PM'),
    ('Ростелеком Академик'),
    ('Оформление планировочных Итэлма'),
    ('ТМК. Сколково'),
    ('16120_1_TUL (ДС5)'),
    ('ИКСпФОН (РД)'),
    ('Европлан'),
    ('Газпромбанк Аквамарин АН,Гурзуф'),
    ('Департамент финансов и кадров'),
    ('Пансионат Дельфин (Крым)'),
    ('Ледовая Арена Кристалл РД АИ'),
    ('Сколково'),
    ('Билайн. Ставрополь,ТПУ Томск'),
    ('РТИ'),
    ('ИТЭЛМА'),
    ('Билайн. Нижний Новгород,Итэлма АМО ЗИЛ'),
    ('Общественное пространство Норильск'),
    ('17110_2_TMK'),
    ('Открытие Спартаковская'),
    ('ВТБ Башня PM');

-- ========================================
-- 3. Вставка данных о сотрудниках
-- ========================================

INSERT INTO employees (last_name, first_name, middle_name, salary, hire_date, position_id, department_id, branch_address_id) VALUES
    ('Суханова', 'Арина', 'Руслановна', 103333.00, '2013-01-20', 
        (SELECT position_id FROM positions WHERE position_name = 'ведущий QA инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр компетенций QA Москва'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Приморский край, г. Владивосток, ул Нижнепортовая, д. 1')),
    
    ('Баранов', 'Георгий', 'Александрович', 12130.00, '2017-12-31',
        (SELECT position_id FROM positions WHERE position_name = 'специалист'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Вишневская', 'Виктория', 'Матвеевна', 12130.00, '2017-11-17',
        (SELECT position_id FROM positions WHERE position_name = 'специалист по персоналу'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Алексеев', 'Константин', 'Николаевич', 12366.00, '2020-06-23',
        (SELECT position_id FROM positions WHERE position_name = 'специалист по персоналу'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2')),
    
    ('Лаптев', 'Владислав', 'Даниилович', 71000.00, '2016-06-22',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2')),
    
    ('Коновалов', 'Даниил', 'Матвеевич', 62000.00, '2013-11-26',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Фролов', 'Тимур', 'Тимофеевич', 55000.00, '2017-03-22',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2')),
    
    ('Левина', 'Елизавета', 'Артёмовна', 33000.00, '2013-03-10',
        (SELECT position_id FROM positions WHERE position_name = 'руководель проектов по интеграции'),
        (SELECT department_id FROM departments WHERE department_name = 'Департамент Техническая поддержка'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Сафонов', 'Леонид', 'Максимович', 60615.00, '2013-11-23',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Журавлев', 'Денис', 'Георгиевич', 33300.00, '2016-03-26',
        (SELECT position_id FROM positions WHERE position_name = 'старший инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Ильина', 'Злата', 'Игоревна', 33250.00, '2016-05-13',
        (SELECT position_id FROM positions WHERE position_name = 'старший инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Дементьев', 'Лев', 'Маркович', 31000.00, '2013-03-23',
        (SELECT position_id FROM positions WHERE position_name = 'инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа первичной диагностики №2'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Шилов', 'Глеб', 'Николаевич', 32000.00, '2017-01-31',
        (SELECT position_id FROM positions WHERE position_name = 'старший инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа Billing'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Еремеев', 'Денис', 'Степанович', 60300.00, '2017-10-23',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа DOC'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Тарасова', 'Анастасия', 'Даниловна', 33752.00, '2015-12-31',
        (SELECT position_id FROM positions WHERE position_name = 'старший инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа ODS'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Высоцкая', 'Ольга', 'Константиновна', 55000.00, '2017-03-16',
        (SELECT position_id FROM positions WHERE position_name = 'инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа Rating'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Богданова', 'Софья', 'Никитична', 56000.00, '2017-01-31',
        (SELECT position_id FROM positions WHERE position_name = 'старший инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа Rating'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Новиков', 'Марк', 'Евгеньевич', 65600.00, '2013-07-10',
        (SELECT position_id FROM positions WHERE position_name = 'руководель сервисных проектов'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр управления сервисами'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Гусева', 'Екатерина', 'Марковна', 60000.00, '2017-07-16',
        (SELECT position_id FROM positions WHERE position_name = 'разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Департамент FBF'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Воробьев', 'Герман', 'Ильич', 136000.00, '2020-07-13',
        (SELECT position_id FROM positions WHERE position_name = 'старший разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Департамент FBF'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Григорьева', 'Вера', 'Константиновна', 135200.00, '2012-03-10',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий архектор'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр анализа и архектуры Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Осипов', 'Андрей', 'Алексеевич', 116600.00, '2012-03-23',
        (SELECT position_id FROM positions WHERE position_name = 'старший архектор'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр анализа и архектуры Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Назарова', 'Мария', 'Альбертовна', 151600.00, '2017-05-23',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Лаптева', 'Анна', 'Максимовна', 33000.00, '2017-01-25',
        (SELECT position_id FROM positions WHERE position_name = 'разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Ситникова', 'Эмилия', 'Николаевна', 132132.00, '2013-03-30',
        (SELECT position_id FROM positions WHERE position_name = 'старший разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Кузнецова', 'Любовь', 'Даниэльевна', 75300.00, '2013-07-27',
        (SELECT position_id FROM positions WHERE position_name = 'старший разработчик'),
        (SELECT department_id FROM departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Трофимов', 'Вячеслав', 'Романович', 67100.00, '2013-07-26',
        (SELECT position_id FROM positions WHERE position_name = 'ведущий инженер'),
        (SELECT department_id FROM departments WHERE department_name = 'Группа инфраструктуры'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Пантелеева', 'Есения', 'Серафимовна', 76550.00, '2017-03-13',
        (SELECT position_id FROM positions WHERE position_name = 'руководель проектов'),
        (SELECT department_id FROM departments WHERE department_name = 'Департамент Rating and Charging'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1')),
    
    ('Зуев', 'Георгий', 'Ильич', 135000.00, '2012-11-21',
        (SELECT position_id FROM positions WHERE position_name = 'руководель направления разработки'),
        (SELECT department_id FROM departments WHERE department_name = 'Департамент Rating and Charging'),
        (SELECT branch_address_id FROM branch_addresses WHERE full_address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'));

-- ========================================
-- 4. Связь сотрудников с проектами
-- ========================================

INSERT INTO employee_projects (employee_id, project_id) VALUES
    (1, (SELECT project_id FROM projects WHERE project_name = 'Итэлма Инженерный корпус')),
    (2, (SELECT project_id FROM projects WHERE project_name = 'Севастополь ТВ')),
    (3, (SELECT project_id FROM projects WHERE project_name = 'Кристалл Доп объем')),
    (4, (SELECT project_id FROM projects WHERE project_name = 'Ростелеком. Гончарная,ВТБ Башня PM')),
    (5, (SELECT project_id FROM projects WHERE project_name = 'Газпромбанк Бирюзова')),
    (6, (SELECT project_id FROM projects WHERE project_name = 'Гпб Оазис Кабинет З.')),
    (7, (SELECT project_id FROM projects WHERE project_name = 'Комплекс Pine Creek Доп работы')),
    (8, (SELECT project_id FROM projects WHERE project_name = 'Сбербанк Нижний Новгород')),
    (9, (SELECT project_id FROM projects WHERE project_name = 'Рособоронэкспорт _ PM')),
    (10, (SELECT project_id FROM projects WHERE project_name = 'Ростелеком Академик')),
    (11, (SELECT project_id FROM projects WHERE project_name = 'Оформление планировочных Итэлма')),
    (12, (SELECT project_id FROM projects WHERE project_name = 'ТМК. Сколково')),
    (13, (SELECT project_id FROM projects WHERE project_name = '16120_1_TUL (ДС5)')),
    (14, (SELECT project_id FROM projects WHERE project_name = 'ИКСпФОН (РД)')),
    (15, (SELECT project_id FROM projects WHERE project_name = 'Европлан')),
    (16, (SELECT project_id FROM projects WHERE project_name = 'Газпромбанк Аквамарин АН,Гурзуф')),
    (17, (SELECT project_id FROM projects WHERE project_name = 'Департамент финансов и кадров')),
    (18, (SELECT project_id FROM projects WHERE project_name = 'Пансионат Дельфин (Крым)')),
    (19, (SELECT project_id FROM projects WHERE project_name = 'Ледовая Арена Кристалл РД АИ')),
    (20, (SELECT project_id FROM projects WHERE project_name = 'Сколково')),
    (21, (SELECT project_id FROM projects WHERE project_name = 'Билайн. Ставрополь,ТПУ Томск')),
    (22, (SELECT project_id FROM projects WHERE project_name = 'РТИ')),
    (23, (SELECT project_id FROM projects WHERE project_name = 'ИТЭЛМА')),
    (24, (SELECT project_id FROM projects WHERE project_name = 'Билайн. Нижний Новгород,Итэлма АМО ЗИЛ')),
    (25, (SELECT project_id FROM projects WHERE project_name = 'Общественное пространство Норильск')),
    (26, (SELECT project_id FROM projects WHERE project_name = '17110_2_TMK')),
    (27, (SELECT project_id FROM projects WHERE project_name = 'Открытие Спартаковская')),
    (28, (SELECT project_id FROM projects WHERE project_name = 'ВТБ Башня PM')),
    (29, (SELECT project_id FROM projects WHERE project_name = 'Сколково'));

-- ========================================
-- 5. Проверка данных
-- ========================================

SELECT 'Таблицы созданы и заполнены!' AS status;
SELECT COUNT(*) AS total_employees FROM employees;
SELECT COUNT(*) AS total_projects FROM projects;
SELECT COUNT(*) AS total_departments FROM departments;