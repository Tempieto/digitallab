-- Данный SQL-скрипт извлекает данные из таблицы online_purcase и создает формирует четыре столбца:
-- 1) Год когорты, когда пользователь совершил первую покупку;
-- 2) Последующие года (которые по условию скрипта больше когортного);
-- 3) Названия компаний, в которых пользователи совершали покупки в последующие года. То есть, названия тех компаний, ради которых пользователи возвращались за покупками;
-- 4) Сколько таких пользователей в той или иной комбинации «Когортный год — Последующий год — Назване магазина»

-- То есть, данный скрипт отвечает на вопрос: «Какие компании удерживают пользователей (в данном случае женщин на тарифе hard, условия можем менять) в разрезе когорт по году первой покупки?»
-- Мы получаем список компаний, ради которых клиенты остаются активными в следующие годы. 

WITH purchase_years AS (
    SELECT
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        company_name
    FROM online_purcase
    WHERE tariff = 'hard' and gender = 'f'
),

first_years AS (
    SELECT 
        person_id, 
        MIN(purchase_year) AS cohort_year
    FROM purchase_years
    GROUP BY person_id
),

user_company_data AS (
    SELECT
        fy.cohort_year,
        py.purchase_year AS retained_year,
        py.person_id,
        py.company_name
    FROM first_years fy
    JOIN purchase_years py
        ON fy.person_id = py.person_id
        AND py.purchase_year > fy.cohort_year
)

SELECT
    cohort_year,
    retained_year,
    company_name,
    COUNT(DISTINCT person_id) AS users_count
FROM user_company_data
GROUP BY cohort_year, retained_year, company_name
ORDER BY cohort_year, retained_year, users_count DESC
LIMIT 100
