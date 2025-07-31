-- В целом простой SQL-запрос. Он обращается к таблице products и создает два столбца:
-- 1) год совершения покупок;
-- 2) количество уникальных (новых) пользователей, которые пришли в сервис.

-- То есть, данный скрипт считает годовую динамику новых пользователей, то есть сколько уникальных людей впервые совершили покупку в каждый год между 2020 и 2025.
-- За счет CTE в самом начале эти пользователи учитываются в запросе только один раз.
-- Фактически скрипт отражает метрику новых пользователей каждый год жизни сервиса

WITH first_appearance AS (
    SELECT 
        person_id, 
        MIN(EXTRACT(YEAR FROM purchase_date)) AS first_year
    FROM products
    WHERE purchase_date BETWEEN '2020-01-01' AND '2025-12-31'
    GROUP BY person_id
)
SELECT 
    first_year AS год,
    COUNT(person_id) AS уникальные_пользователи
FROM first_appearance
GROUP BY first_year
ORDER BY first_year;
