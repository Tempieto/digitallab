-- SQL-скрипт также обращается к таблице online_purchases, фильтрует их по тарифу и полу, а по результатам работы возвращает пять столбцов:
-- 1) Год когорты (год первой покупки, когда пользователь пришел в продукт);
-- 2) Последующие годы (следующие после года когорты);
-- 3) Средний возраст пользователей того или иного когортного года, остающихся в продукте в каждый последующий год;
-- 4) Медианны возраст пользователей того или иного когортного года, остающихся в продукте в каждый последующий год;
-- 5) Количество пользователей той или иной когорты, остающихся в каждый последующий год.

-- То есть, данный скрипт полезен для когортного анализа по возрасту и отвечает на вопрос «Каков средний и медианный возраст женщин на тарифе best в момент удержания, и сколько их?»
-- Он позволяет увидеть, в каком возрасте приходят клиенты (по cohort_year) и как меняется средний возраст в годы удержания.
-- При этом во избежания выбросов используется не только среднее арифметическое, но и медиана, так как среднее может искажаться «выбросами» (например, если несколько пользователей старше 80 лет).
-- Запрос позволяет проверить, какие возрастные группы чаще возвращаются. Например, окажется, что молодые пользователи быстро «отваливаются», а более взрослые дольше остаются.

WITH purchase_years AS (
    SELECT
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        age_at_purchase
    FROM online_purchases
    WHERE tariff = 'best' and gender = 'f'
),

first_years AS (
    SELECT 
        person_id, 
        MIN(purchase_year) AS cohort_year
    FROM purchase_years
    GROUP BY person_id
),

user_year_data AS (
    SELECT
        fy.cohort_year,
        py.purchase_year AS retained_year,
        py.person_id,
        py.age_at_purchase
    FROM first_years fy
    JOIN purchase_years py
        ON fy.person_id = py.person_id
        AND py.purchase_year >= fy.cohort_year
)

SELECT
    cohort_year,
    retained_year,
    ROUND(AVG(age_at_purchase), 2) AS avg_age,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age_at_purchase) AS median_age,
    COUNT(DISTINCT person_id) AS users_count
FROM user_year_data
GROUP BY cohort_year, retained_year
ORDER BY cohort_year, retained_year;
