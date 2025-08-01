-- Данный SQL-запрос обращается к таблице online_purcase, фильтрует их по tariff и gender, и по результатам работы создает четыре столбца: 
-- 1) год когорты пользователя;  
-- 2) год покупки, когда пользователь остался в сервисе (год можем редактировать);  
-- 3) person_id пользователей; 
-- 4) сумма покупок в год покупки

-- То есть, с помощью данного запроса мы формируем год когорты пользователей по году их первой активности и проверяем, вернулся ли пользователь на возврат в заданный год (в данном случае это 2025 год);
-- Через SUM(purchase_amount) получается сумма покупок за 2025 год для каждого пользователя (и когорты);
-- Польза: Можно понять, сколько пользователей (смотрим на кол-во строк) из разных когорт «дожили» до 2025 года и вернулись с покупкой;
-- Данный запрос можно усовершенствовать и построить уже цельную когортную матрицу с удержанием (the_retention_matrix.sql)

WITH purchases AS (
select
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        sum(purchase_amount) as purchase_amount
    FROM online_purchases
    WHERE tariff = 'hard' and gender = 'm'
GROUP BY person_id, purchase_year
),
    cohorts AS (
    SELECT
        person_id,
        MIN(purchase_year) AS cohort_year
    FROM purchases
    GROUP BY person_id
)
SELECT
        c.cohort_year,
        p.purchase_year AS retained_year,
        p.person_id,
        p.purchase_amount
    FROM cohorts c
    JOIN purchases p
        ON c.person_id = p.person_id
where p.purchase_year = 2025 and c.cohort_year = 2023;
