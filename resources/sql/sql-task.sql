--1
--Вывести к каждому самолету класс обслуживания и количество мест этого класса:
SELECT aircrafts_data.model, seats.fare_conditions, count(seats.seat_no) AS seats_count
FROM aircrafts_data,
     seats
GROUP BY aircrafts_data.model, seats.fare_conditions
ORDER BY aircrafts_data.model;


--2
--Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT aircrafts_data.model, count(seats.seat_no) AS seats_count
FROM aircrafts_data,
     seats
WHERE aircrafts_data.aircraft_code = seats.aircraft_code
GROUP BY aircrafts_data.model
ORDER BY seats_count DESC LIMIT 3;


--3
--Найти все рейсы, которые задерживались более 2 часов
SELECT *
FROM flights
WHERE (actual_departure - scheduled_departure) > INTERVAL '2 hours';


--4
--Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'),
--с указанием имени пассажира и контактных данных
SELECT tickets.passenger_name, tickets.contact_data, ticket_flights.fare_conditions, bookings.book_date
FROM tickets
         JOIN ticket_flights USING (ticket_no)
         JOIN bookings USING (book_ref)
WHERE ticket_flights.fare_conditions = 'Business'
ORDER BY bookings.book_date DESC LIMIT 10;


--5
--Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT *
FROM flights
         LEFT JOIN ticket_flights
                   ON flights.flight_id = ticket_flights.flight_id
                       AND ticket_flights.fare_conditions = 'Business'
WHERE ticket_flights.ticket_no IS NULL;


--6
--Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT airports_data.airport_name, airports_data.city
FROM airports_data
         JOIN flights
              ON airports_data.airport_code = flights.departure_airport
WHERE (actual_departure - scheduled_departure) > interval '0 seconds';


--7
--Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта,
--отсортированный по убыванию количества рейсов
SELECT airports_data.airport_name, count(flights.flight_no) AS flights_count
FROM airports_data,
     flights
WHERE airports_data.airport_code = flights.departure_airport
GROUP BY airports_data.airport_name
ORDER BY flights_count DESC;


--8
--Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival)
--было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT *
FROM flights
WHERE scheduled_arrival != actual_arrival;


--9
--Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200"
--с сортировкой по местам
SELECT aircrafts_data.aircraft_code, aircrafts_data.model, seats.seat_no
FROM aircrafts_data
         JOIN seats USING (aircraft_code)
WHERE seats.fare_conditions != 'Economy'
AND aircrafts_data.model = 'Аэробус A321-200'
ORDER BY seats.seat_no;


--10
--Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airports_data.airport_code, airports_data.airport_name, airports_data.city
FROM airports_data
         JOIN (SELECT city, COUNT(airport_code) AS airports_count
               FROM airports_data
               GROUP BY city) counts
              ON airports_data.city = counts.city
WHERE counts.airports_count > 1;


--11
--Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT tickets.passenger_id, tickets.passenger_name, tickets.contact_data
FROM tickets
WHERE (SELECT SUM(ticket_flights.amount)
       FROM ticket_flights
       WHERE ticket_flights.ticket_no = tickets.ticket_no) > (SELECT AVG(ticket_flights.amount)
                                                              FROM ticket_flights);


--12
--Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flights.flight_no,
       flights.status,
       flights.scheduled_departure,
       departure_airports.city AS departure_city,
       arrival_airports.city   AS arrival_city
FROM flights
         JOIN airports AS departure_airports ON flights.departure_airport = departure_airports.airport_code
         JOIN airports AS arrival_airports ON flights.arrival_airport = arrival_airports.airport_code
WHERE departure_airports.city = 'Екатеринбург'
  AND arrival_airports.city = 'Москва'
  AND flights.scheduled_departure > bookings.now()
ORDER BY flights.scheduled_departure ASC LIMIT 1;


--13
--Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT *
 FROM ticket_flights
 ORDER BY amount LIMIT 1)
UNION
(SELECT *
 FROM ticket_flights
 ORDER BY amount DESC LIMIT 1);


--14
--Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone.
--Добавить ограничения на поля (constraints)
CREATE TABLE bookings.customers
(
    id         BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50)        NOT NULL,
    last_name  VARCHAR(50)        NOT NULL,
    email      VARCHAR(50) UNIQUE NOT NULL,
    phone      VARCHAR(50)        NOT NULL,
);


--15
--Написать DDL таблицы Orders, должен быть id, customerId, quantity.
--Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE bookings.orders
(
    id          BIGSERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    quantity    INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES bookings.customers (id)
);


--16
--Написать 5 insert в эти таблицы
INSERT INTO customers(first_name, last_name, email, phone)
VALUES ('Иван', 'Иванов', 'uu@mail.ru', '+37529111111'),
       ('Дмитрий', 'Дмитриев', 'j@mail.ru', '+37529111112'),
       ('Кирилл', 'Кириллов', 'jd@mail.ru', '+37529111113'),
       ('Петр', 'Петров', 'jhh@mail.ru', '+37529111114'),
       ('Андрей', 'Андреев', 'jqh@mail.ru', '+37529111115');
INSERT INTO orders(customer_id, quantity)
VALUES ((SELECT id FROM customers WHERE phone = '+37529111111'), 100),
       ((SELECT id FROM customers WHERE phone = '+37529111112'), 200),
       ((SELECT id FROM customers WHERE phone = '+37529111113'), 300),
       ((SELECT id FROM customers WHERE phone = '+37529111114'), 400),
       ((SELECT id FROM customers WHERE phone = '+37529111115'), 500);


--17
--Удалить таблицы
DROP TABLE customers, orders;