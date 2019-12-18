-- Coding UTF-8
USE kinopoisk;

-- ===== Получим список актеров и год производства фильма id = 1 =====
SELECT
	concat(a_d.firstname, ' ', a_d.lastname) AS fullname,
	a_d.status, 
	m.title AS title_movie,
	y.`year` AS year_production
FROM actors_and_directors AS a_d
JOIN movies AS m ON m.id = a_d.movie_id
JOIN years AS y ON y.id = m.movie_year_id
WHERE m.id = 1
AND a_d.status = 'actor'
-- AND a_d.status = 'director' -- Для получение режиссеров
;

-- ===== Получим топ 10 фильмов по среднему рейтингу =====

SELECT
	m.id AS id_movie,
	m.title AS title_movie,
	round(avg(s.stars), 2) AS rating_movie
FROM stars_movie AS s
JOIN movies AS m ON m.id = s.movie_id
GROUP BY m.id
ORDER BY rating_movie DESC
LIMIT 10;

-- ===== Получим новости =====
SELECT *
FROM news;

-- ===== Получим комментарии =====
SELECT *
FROM comments;

-- ===== Получим комментарии для всех новостей =====
SELECT
	n.id AS news_id,
	n.title AS news_title,
	concat(u.firstname, ' ', u.lastname) AS user_full_name,
	c.comment AS user_comment,
	c.created_at AS comment_created_at
FROM news AS n
JOIN comments AS c ON n.id = c.news_id
JOIN users AS u ON u.id = c.user_id
-- WHERE n.id = 1 -- Для конктретной новости
ORDER BY n.id
;

-- ===== Получим кто больше оставил комментариев в новостях (мужчины или женщины) =====
SELECT
	gender,
	count(*) AS count_comments
FROM profiles p
JOIN users AS u ON u.id = p.user_id
JOIN comments AS c ON c.user_id = u.id
GROUP BY p.gender;

-- ===== Получим информацию о актерах из России и отсортируем их по росту от высокого к низкому =====
SELECT
	firstname,
	lastname,
	birthday,
	height,
	c.title_country
FROM actors_and_directors AS a_d
JOIN countries AS c ON c.id = a_d.country_id
WHERE status = 'actor'
AND c.title_country = 'Russia'
ORDER BY a_d.height DESC
-- LIMIT 10 -- Для получения 10-и самых высоких актеров из России
;

-- ===== Получим 10 самых молодых режиссеров из России от 18-и лет (Имя, Фамилия, статус, дата рождения, возраст) =====
-- и их фильмы (год фильма, страна производства)
SELECT
	concat(a_d.firstname, ' ', a_d.lastname) AS full_name,
	a_d.status,
	c.title_country AS country_director,
	a_d.birthday,
	TIMESTAMPDIFF(YEAR, a_d.birthday, NOW()) AS age,
	m.title AS movie_title,
	y.`year` AS movie_year,
	c2.title_country AS movie_country
FROM actors_and_directors a_d
JOIN countries AS c ON c.id = a_d.country_id
JOIN movies AS m ON m.id = a_d.movie_id
JOIN years AS y ON y.id = m.movie_year_id
JOIN countries AS c2 ON c2.id = m.country_production_id
WHERE a_d.status = 'director'
AND c.title_country = 'Russia'
AND TIMESTAMPDIFF(YEAR, a_d.birthday, NOW()) >= 18
ORDER BY age
LIMIT 10
;

-- ===== Получим фильм/фильмы, которому/которым пользователь с id = 1 поставил наивысшую оценку =====
SELECT
	concat(u.firstname, ' ', u.lastname) AS full_name,
	m.title AS movie_title,
	sm.stars
FROM users AS u
JOIN profiles AS p ON p.user_id = u.id
JOIN stars_movie AS sm ON sm.user_id = u.id
JOIN movies AS m ON m.id = sm.movie_id
WHERE u.id = 1
GROUP BY m.title
ORDER BY sm.stars DESC
LIMIT 1
-- LIMIT 3
;

-- ===== Получим все максимальные оценки пользователей к списку фильмов =====
SELECT
	concat(u.firstname, ' ', u.lastname) AS full_name,
	m.title AS movie_title,
	sm.stars
FROM users AS u
JOIN profiles AS p ON p.user_id = u.id
JOIN stars_movie AS sm ON sm.user_id = u.id
JOIN movies AS m ON m.id = sm.movie_id
GROUP BY m.title
ORDER BY sm.stars DESC
;

-- ===== Получим оценки фильмов друзей =====

-- Обновим для наглядности первые 5 initiator_user_id (сделаем их = 1)
UPDATE friend_requests
SET initiator_user_id = 1
WHERE initiator_user_id < 6;

UPDATE friend_requests
	SET target_user_id = 1, status='approved'
	WHERE initiator_user_id=6 AND target_user_id = 7;

UPDATE friend_requests
	SET target_user_id = 1, status='approved'
	WHERE initiator_user_id = 7 AND target_user_id = 8;

-- Далее получаем сами фильмы и оценки друзей
SELECT
	concat(u.firstname, ' ', u.lastname) AS my_name,
	concat(u_2.firstname, ' ', u_2.lastname) AS my_friend_name,
-- 	fr.status,
	m.title AS movie_name,
	sm.stars AS friends_stars
FROM friend_requests AS fr
JOIN users AS u ON u.id = fr.initiator_user_id
JOIN users AS u_2 ON u_2.id = fr.target_user_id
JOIN stars_movie AS sm ON sm.user_id = u_2.id
JOIN movies AS m ON m.id = sm.movie_id
WHERE u.id = 1
AND fr.status = 'approved'
ORDER BY u_2.id, sm.stars DESC
;
-- Проверка
SELECT stars
FROM stars_movie sm
WHERE user_id = 2;

-- Обновим интересы нескольким пользователям
UPDATE kinopoisk.profiles
SET interests='Placeat quia error aliquid ab. Sunt repellat beatae ratione omnis. 
			Atque deleniti consequuntur earum. Est deserunt nam odio totam repudiandae voluptatem autem.'
WHERE user_id = 3 OR user_id = 2 OR user_id = 4;

-- ===== Получаем количество мужчин и женщин =====
-- Обновим данные таблицы
UPDATE profiles
SET gender = 'M'
WHERE user_id < 201;

UPDATE profiles
SET gender = 'F'
WHERE user_id > 200;

-- Получаем количество
SELECT
	gender,
	count(*) AS count_gender
FROM profiles
GROUP BY gender;

-- ===== Получим общее количество оценок, которые получили фильмы производства 2010 г и выше =====
SELECT
	count(*),
	m.title
FROM stars_movie AS sm
JOIN movies AS m ON m.id = sm.movie_id
JOIN years AS y ON y.id = m.movie_year_id
WHERE y.`year` > 2010
GROUP BY m.title;

-- ===== Получим жанр фильма, которыого больше всех снято =====
-- Обновим данные таблицы для наглядности
--  Auto-generated SQL script #201912182130
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=1;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=2;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=3;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=4;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=5;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=6;
UPDATE kinopoisk.movies
	SET movie_genre_id=15
	WHERE id=7;

-- Получаем самый популярный жанр
SELECT	
	g.genre AS movie_genre,
	count(*) AS amount_movie
FROM genres g
JOIN movies AS m ON m.movie_genre_id = g.id
GROUP BY g.genre
ORDER BY amount_movie DESC
LIMIT 1;

-- ===== Выборка самый высокий рейтинг фильма жанра "Комедия" =====
SELECT
	m.title AS movie_title,
	g.genre AS movie_genre,
	avg(sm.stars) AS movie_rating
FROM movies m
JOIN stars_movie AS sm ON sm.movie_id = m.id
JOIN genres AS g ON g.id = m.movie_genre_id
WHERE m.movie_genre_id = 15
GROUP BY m.id
ORDER BY movie_rating DESC
LIMIT 1;

-- ===== Выборка актеров из Канады чей рост более 2 м. Предположим, что мы не знаем id страны =====
SELECT
	concat (aad.firstname, ' ', aad.lastname) AS actor_name,
	aad.height AS actor_height,
	c.title_country AS actor_country
FROM actors_and_directors aad
JOIN countries AS c ON c.id = aad.country_id
WHERE aad.height > 2
AND aad.status = 'actor'
AND c.title_country LIKE 'canad%'
ORDER BY aad.height DESC;

-- ===== Выборка кто написал сколько сообщений =====
SELECT
	users.id, users.firstname,
	count(*) AS total_messages
FROM users
JOIN messages
	ON users.id = messages.from_user_id
GROUP BY users.id
ORDER BY total_messages DESC;

-- ===== Получим сообщения пользователя =====
-- Обновим данные
--  Auto-generated SQL script #201912182043
UPDATE kinopoisk.messages
	SET from_user_id=1
	WHERE id=2;
UPDATE kinopoisk.messages
	SET from_user_id=1
	WHERE id=3;
UPDATE kinopoisk.messages
	SET from_user_id=1
	WHERE id=4;
UPDATE kinopoisk.messages
	SET to_user_id=1
	WHERE id=5;
UPDATE kinopoisk.messages
	SET to_user_id=1
	WHERE id=6;
UPDATE kinopoisk.messages
	SET to_user_id=1
	WHERE id=7;

-- Сообщения к пользователю
SELECT
	concat(u.firstname, ' ', u.lastname) AS to_user,
	m.body,
	m.created_at
FROM messages AS m
JOIN users AS u ON u.id = m.to_user_id
WHERE u.id = 1;
  
-- Сообщения от пользователя
SELECT
	concat(u.firstname, ' ', u.lastname) AS drom_user,
	m.body,
	m.created_at
FROM messages AS m
JOIN users AS u ON u.id = m.from_user_id
WHERE u.id = 1;

-- ===== Количество друзей у всех пользователей =====
SELECT firstname, lastname, COUNT(*) AS total_friends
FROM users
JOIN friend_requests ON (users.id = friend_requests.initiator_user_id or users.id = friend_requests.target_user_id)
where friend_requests.status = 'approved'
GROUP BY users.id
ORDER BY total_friends DESC;

-- ===== Выборка оценок фильмов друзей пользователя =====
SELECT
	sm.*,
	concat(u_2.firstname, ' ', u_2.lastname) AS full_name,
	m.title AS movie_title
FROM stars_movie AS sm
JOIN friend_requests fr ON sm.user_id = fr.target_user_id
JOIN users ON fr.initiator_user_id = users.id -- кому я отправлял заявку в друзья
JOIN movies AS m ON m.id = sm.movie_id
JOIN users AS u_2 ON u_2.id = sm.user_id
WHERE users.id = 1
	AND fr.status = 'approved'
UNION
SELECT
	sm.*,
	concat(u_2.firstname, ' ', u_2.lastname) AS full_name,
	m.title AS movie_title
FROM stars_movie AS sm
JOIN friend_requests fr ON sm.user_id = fr.initiator_user_id
JOIN users ON fr.target_user_id = users.id   -- кто мне отправлял заявку в друзья
JOIN movies AS m ON m.id = sm.movie_id
JOIN users AS u_2 ON u_2.id = sm.user_id
WHERE users.id = 1
	AND fr.status = 'approved'
ORDER BY created_at desc;

-- ===== Выборка юзера, который больше всех общался с нашим пользователем =====

SELECT 
	from_user_id,
	concat(u.firstname, ' ', u.lastname) as name,
	count(*) as 'messages count'
FROM messages m
JOIN users u on u.id = m.from_user_id
WHERE to_user_id = 1
GROUP BY from_user_id
ORDER BY count(*) desc
LIMIT 1;