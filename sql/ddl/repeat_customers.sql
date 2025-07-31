-- SQL-запрос обращается к таблице products, фильтрует по времени и типу транзакции ('food') и по результатам работы возвращает четыре столбца:
-- 1) Год, когда пользователи совершали покупки в сервисе;
-- 2) Общее число покупателей;
-- 3) Количество покупателей, которые совершили более одной покупки;
-- 4) коэффициент повторной покупки (RPR, repeat purchase rate), считающийся по формуле: (кол-во пользователей, совершивших более одной покупки / все пользователи когорты в тот или иной год) * 100;

-- Данный запрос показывает, как много всего приходилось покупателей сервиса на тот или иной год; количество пользователей, которые совершили более одной покупки (то есть, вернулись, после первой) и RPR.
-- Чем выше RPR, тем выше вовлечённость и «качество» аудитории. Этот скрипт можно изменять, добавлять новые условия фильтрации для пользователей, конкретизировать когорты.
-- В данном виде он дает знать, как менялся RPR продукта в том или ином направлении в течение нескольких лет.

SELECT 
    year,
    COUNT(DISTINCT person_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN purchase_count > 1 THEN person_id END) AS repeat_customers,
    ROUND(COUNT(DISTINCT CASE WHEN purchase_count > 1 THEN person_id END) * 100.0 / COUNT(DISTINCT person_id), 2) AS RPR
FROM (
    SELECT 
        person_id, 
        EXTRACT(YEAR FROM purchase_date) AS year,
        COUNT(*) AS purchase_count 
    FROM products
    WHERE purchase_date BETWEEN '2021-01-01' AND '2025-12-31'
      AND transaction_type = 'food'
    GROUP BY person_id, year
) subquery
GROUP BY year
ORDER BY year;
