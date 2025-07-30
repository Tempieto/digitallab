-- SQL-запрос обращается к таблице products.csv и по итогу возвращает четыре столбца:
-- 1) год транзакции;
-- 2) возраст человека;
-- 3) кол-во женщин;
-- 4) кол-во женщин.

-- То есть, запрос дает знать, сколько приходится женщин и мужчин того или иного возраста в тарифе food (опционально) в 2024 году (опционально). 
-- За счет CTE first_purchase_2024 и джойна в основном запросе в результат попадает ровно одна строка на каждого пользователя, даже если он потом сделал ещё 20 покупок в том же году.
-- Это позволяет корректно построить половозрастную гистограмму покупателей сервиса в том или ином году, в том или ином тарифе без дублирования из-за повторных транзакций.

WITH first_purchase_2024 AS (
    SELECT 
        person_id,
        MIN(purchase_date) AS first_tdate
    FROM products
    WHERE EXTRACT(YEAR FROM purchase_date) = 2024
      AND transaction_type = 'food'
    GROUP BY person_id
)
SELECT 
    EXTRACT(YEAR FROM p.purchase_date) AS год,
    p.age_at_purchase AS возраст,  
    COUNT(DISTINCT CASE WHEN p.gender = 'f' THEN p.person_id END) AS женщины,
    COUNT(DISTINCT CASE WHEN p.gender = 'm' THEN p.person_id END) AS мужчины
FROM products p
JOIN first_purchase_2024 fp 
    ON p.person_id = fp.person_id 
    AND p.purchase_date = fp.first_tdate
WHERE p.age_at_purchase BETWEEN 18 AND 90
  AND p.transaction_type = 'food'
GROUP BY 1, 2
ORDER BY 1, 2;
