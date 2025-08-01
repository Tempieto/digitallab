-- SQL-запрос обращается к таблице online_purchases, фильтрует их по тарифу, гендеру и возвращает четыре столбца:
-- 1) год когорты пользователя;  
-- 2) год покупки, когда пользователь остался в сервисе (год можем редактировать);  
-- 3) средний чек в тот или иной год покупки;
-- 4) медианный чек в тот или иной год покупки.

-- Этот запрос, как и запрос, размещенный в avg_and_median_ages.sql, использует две меры центральной тенденции – медиану и среднее арифметическое. 
-- Медиана, как более устойчивая к выбросам мера центральной тенденции, особенно актуальна при тех наборах данных, где могут наблюдаться выбросы. Яркимй пример – суммы покупок;
-- С помощью данного SQL-скрипта мжно увидеть, как меняется средний и медианный чек у пользователей разных когорт.
-- Он также позволяет понять, есть ли выбросы в суммах покупок (если avg_check сильно выше median_check, значит, часть пользователей делает аномально дорогие покупки)
Таким образом, скрипт помогает ответить на вопрос: «Сколько в среднем тратят пользователи в разные годы после первой покупки и меняется ли их поведение со временем?»

WITH purchases AS (
    SELECT
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        purchase_amount
        FROM online_purchases
    WHERE tariff = 'fast' and gender = 'm'
),

cohorts AS (
    SELECT
        person_id,
        MIN(purchase_year) AS cohort_year
    FROM purchases
    GROUP BY person_id
),

retained_purchases AS (
    SELECT
        c.cohort_year,
        p.purchase_year AS retained_year,
        p.person_id,
        p.purchase_amount
    FROM cohorts c
    JOIN purchases p
        ON c.person_id = p.person_id
        AND p.purchase_year >= c.cohort_year
),

aggregates AS (
    SELECT
        cohort_year,
        retained_year,
        COUNT(DISTINCT person_id) AS retained_users,
        ROUND(AVG(purchase_amount), 2) AS avg_check,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY purchase_amount) AS median_check
    FROM retained_purchases
    GROUP BY cohort_year, retained_year
),

cohort_sizes AS (
    SELECT
        cohort_year,
        COUNT(DISTINCT person_id) AS cohort_size
    FROM cohorts
    GROUP BY cohort_year
)

SELECT
    a.cohort_year,
    a.retained_year,
	  a.avg_check,
    a.median_check
FROM aggregates a
JOIN cohort_sizes cs
    ON a.cohort_year = cs.cohort_year
ORDER BY a.cohort_year, a.retained_year;
