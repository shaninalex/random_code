/*

COMMANDS

\d <table_name> - показать таблицу
\dt - показать все таблицы ( public schema )
\s <file_path> - сохранить всю историю выполненных вами команд в текстовом файле

*/


/*

  CREATE TABLE

  Синтаксис:
  CREATE TABLE имя-таблицы
  (
    имя-поля тип-данных [ограничения-целостности],
    имя-поля тип-данных [ограничения-целостности],
    ...
    имя-поля тип-данных [ограничения-целостности],
    [ограничение-целостности],
    [первичный-ключ],
    [внешний-ключ]
  );

*/
-- Создние таблицы в базе данных
CREATE TABLE aircrafts
( aircraft_code char( 3 ) NOT NULL,
  model text NOT NULL,
  range integer NOT NULL,
  CHECK ( range > 0 ),
  PRIMARY KEY ( aircraft_code )
);

/*

demo=# \d aircrafts
                   Table "public.aircrafts"
    Column     |     Type     | Collation | Nullable | Default 
---------------+--------------+-----------+----------+---------
 aircraft_code | character(3) |           | not null | 
 model         | text         |           | not null | 
 range         | integer      |           | not null | 


Indexes:
    "aircrafts_pkey" PRIMARY KEY, btree (aircraft_code)

-- Ограничения
Check constraints:

    -- Должно быть больше нуля. Имя ограничения
    -- было сгенерированно с нуля самой базой данных
    "aircrafts_range_check" CHECK (range > 0) 

*/



/*

    INSERT

    Синтаксис:
    INSERT INTO 
      имя-таблицы [( имя-атрибута, имя-атрибута, ... )]
    VALUES ( значение-атрибута, значение-атрибута, ... );

*/
-- Вставка в таблицу
INSERT INTO 
  -- Название и перечисление аргументов ( столбцов таблицы )
  aircrafts (aircraft_code, model, range) 
VALUES 
  -- Значения идущие по порядку согласно порядку аргументов выше
  ('SU9', 'Sukhoi SuperJet-100', 3000);

INSERT INTO 
  aircrafts ( aircraft_code, model, range )
VALUES 
  ( '773', 'Boeing 777-300', 11100 ),
  ( '763', 'Boeing 767-300', 7900 ),
  ( '733', 'Boeing 737-300', 4200 ),
  ( '320', 'Airbus A320-200', 5700 ),
  ( '321', 'Airbus A321-200', 5600 ),
  ( '319', 'Airbus A319-100', 6700 ),
  ( 'CN1', 'Cessna 208 Caravan', 1200 ),
  ( 'CR2', 'Bombardier CRJ-200', 2700 );


/*

    SELECT

    Синтаксис:
    SELECT имя-атрибута, имя-атрибута, ...
      FROM имя-таблицы;

*/
-- Взять все данные из таблицы
SELECT * FROM aircrafts;

-- Взять данные из таблицы в границах дальности между 4000 и 6000
SELECT model, aircraft_code, range
 FROM aircrafts 
 WHERE range >= 4000 AND range <= 6000;

-- Взять данные из таблицы отсортируя их по дальности ( от меньшего к большему )
SELECT model, aircraft_code, range
 FROM aircrafts 
 ORDER BY range; 

-- Взять данные из таблицы отсортируя по названию в алфавитном порядке
SELECT model, aircraft_code, range
 FROM aircrafts 
 ORDER BY model;


/*

  UPDATE

  Синтаксис:
  UPDATE имя-таблицы
    SET имя-атрибута1 = значение-атрибута1,
        имя-атрибута2 = значение-атрибута2, ...
    WHERE условие;
*/
UPDATE aircrafts
SET range = 3500,
    model = 'Sukhoy SuperJet-100'
WHERE aircraft_code = 'SU9';


/*

  DELETE

  Синтаксис:
  DELETE FROM имя-таблицы WHERE условие;
*/
-- удаление всех строк у которых значение aircraft_code равно "CN1"
DELETE FROM aircrafts WHERE aircraft_code = 'CN1';

-- удаление всех строк у которых значение range находится больше 10-и тысяч и 3-х тысяч
DELETE FROM aircrafts WHERE range > 10000 OR range < 3000;

-- удаление всех строк таблицы
DELETE FROM aircrafts;
