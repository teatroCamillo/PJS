BEGIN;

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY,
    phone_number TEXT,
    delivery TEXT,
    price REAL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS open_hours (
    id INTEGER PRIMARY KEY,
    mon TEXT,
    tue TEXT,
    wed TEXT,
    thu TEXT,
    fri TEXT,
    sat TEXT,
    sun TEXT,
    location TEXT
);

INSERT OR IGNORE INTO open_hours (id, mon, tue, wed, thu, fri, sat, sun, location)
VALUES (1, '8.00 - 21.00', '8.00 - 21.00', '8.00 - 21.00', '8.00 - 21.00', '8.00 - 21.00', '9.00 - 00.00', '9.00 - 00.00', 'Krakow');

CREATE TABLE IF NOT EXISTS menu (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL,
    description TEXT,
    type TEXT
);

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (1, 'Margherita', 25.55, 'Sos pomidorowy, ser mozzarella, bazylia.', 'pizza_type');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (2, 'Hawajska', 28.00, 'Sos pomidorowy, ser mozzarella, szynka, ananas.', 'pizza_type');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (3, 'Pepperoni', 30.90, 'Sos pomidorowy, ser mozzarella, pepperoni.', 'pizza_type');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (4, 'Fanta', 5.90, 'Napój gazowany 500ml.', 'drink');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (5, 'Coca-Cola', 5.90, 'Napój gazowany 500ml.', 'drink');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (6, 'Woda', 5.00, 'Napój niegazowany 500ml.', 'drink');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (7, 'ser', 5.00, 'Dodatkowy ser.', 'toppings');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (8, 'pieczarki', 5.00, 'Dodatkowe pieczarki.', 'toppings');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (9, 'bekon', 5.00, 'Dodatkowy bekon.', 'toppings');

INSERT OR IGNORE INTO menu (id, name, price, description, type)
VALUES (10, 'brak', 0.00, 'Klient nie wybrał produktu', 'other');

COMMIT;

