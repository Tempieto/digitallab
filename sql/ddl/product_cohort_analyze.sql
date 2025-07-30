-- Данный SQL-скрипт касается продуктовой части анализа таблицы online_purcase, когорты тарифа "hard". Он возвращает шесть столбцов:
-- 1) год когорты;
-- 2) последующие года;
-- 3) оставшиеся («дожившие пользователи»);
-- 4) размер когорты;
-- 5) retention когорты;
-- 6) коэффициент повторной покупки (RPR, repeat purchase rate), считающийся по формуле: (кол-во пользователей, совершивших более одной покупки / все пользователи когорты в тот или иной год) * 100;

-- Чем полезен скрипт: retention показывает, какая доля пользователей из когорты продолжает покупать в последующие годы. 
-- RPR в свою очередь дополняет retention: важно не только, что пользователь вернулся, но и стал ли он регулярным покупателем.
-- Например, высокий retention и низкий RPR может говорить о том, что люди вернулись, но слабо вовлеклись и почти не покупают. 
-- Низкий retention и высокий RPR скажет о том, что мало кто вернулся, но вернувшиеся стали лояльными (стали чаще покупать).

-- Сегментация по когортам позволяет сравнить поведение пользователей, которые пришли в разные годы, и выявить: улучшается ли удержание с ростом сервиса, или наоборот падает.

WITH purchase_years AS (
    SELECT
        person_id,
        EXTRACT(YEAR FROM purchase_date) AS purchase_year,
        gender
    FROM online_purcase
    WHERE tariff = 'hard'
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
        py.person_id
    FROM first_years fy
    JOIN purchase_years py
        ON fy.person_id = py.person_id
        AND py.purchase_year >= fy.cohort_year
),
purchase_counts AS (
    SELECT
        cohort_year,
        retained_year,
        person_id,
        COUNT(*) AS purchases
    FROM user_year_data
    GROUP BY cohort_year, retained_year, person_id
),
retention_and_rpr AS (
    SELECT
        cohort_year,
        retained_year,
        COUNT(DISTINCT person_id) AS retained_users,
        COUNT(DISTINCT CASE WHEN purchases > 1 THEN person_id END) AS repeat_buyers
    FROM purchase_counts
    GROUP BY cohort_year, retained_year
),
cohort_sizes AS (
    SELECT
        cohort_year,
        COUNT(DISTINCT person_id) AS cohort_size
    FROM first_years
    GROUP BY cohort_year
)
SELECT
    rr.cohort_year,
    rr.retained_year,
    rr.retained_users,
    cs.cohort_size,
    ROUND((rr.retained_users * 100.0) / cs.cohort_size, 2) AS retention_rate_percent,
    ROUND((rr.repeat_buyers * 100.0) / rr.retained_users, 2) AS rpr_percent
FROM retention_and_rpr rr
JOIN cohort_sizes cs ON rr.cohort_year = cs.cohort_year
ORDER BY rr.cohort_year, rr.retained_year;
