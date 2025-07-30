-- Данный SQL-скрипт – чуть более измененный и дополненный скрипт, размещенный в файле cohort_analyze1.sql. Если предыдущий скрипт выводит все person_id покупателей того или иного года когорты в том или ином году, то данный скрипт создает так называемую retention-матрицу.
-- По результату выполнения скрипт создает четыре столбца:
-- 1) год когорты;
-- 2) год удержания;
-- 3) количество пользователей, доживших до года удержания (если год когорты и год удержания совпадают, то кол-во пользователей – размер когорты);
-- 4) объем средств, которые пользователи той или иной когорты потратили в тот или иной год удержания.
-- Таким образом, мы можем посчитать LTV каждой когорты по базовой формуле: Общий доход / Количество клиентов

WITH purchases AS (
    SELECT
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        SUM(purchase_amount) AS total_amount
    FROM online_purcase
    WHERE tariff = 'hard' AND gender = 'm'
    GROUP BY person_id, EXTRACT(YEAR FROM purchase_date)
),
cohorts AS (
    SELECT
        person_id,
        MIN(purchase_year) AS cohort_year
    FROM purchases
    GROUP BY person_id
),
cohort_purchases AS (
    SELECT
        c.cohort_year,
        p.purchase_year,
        COUNT(DISTINCT p.person_id) AS users_cnt,         
        SUM(p.total_amount) AS revenue    
        from cohorts c         
        JOIN purchases p
        ON c.person_id = p.person_id
    GROUP BY c.cohort_year, p.purchase_year)
    select 
    *
    from cohort_purchases;
