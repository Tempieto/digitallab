# Data Dictionary
⚠️ Все данные искусственно сгенерированы и не отражают реальных пользователей или компаний

## Таблица: online_purchases.csv
Искусственно сгенерированные чеки онлайн‑покупок

### Столбцы:
- **purchase_id** (UUID) — уникальный идентификатор чека
- **company_name** (string) — название компании, где совершена покупка
- **person_id** (UUID) — уникальный идентификатор пользователя
- **gender** (string) — пол пользователя (`m` или `f`)
- **tariff** (string) — тариф (одно из 7 значений):
  - hard
  - harder
  - best
  - bester
  - fast
  - faster
  - stronger
- **purchase_amount** (numeric) — сумма покупки
- **purchase_date** (date) — дата покупки
- **birth_date** (date) — дата рождения пользователя
- **age_at_purchase** (integer) — возраст пользователя на момент покупки (в годах)

## Таблица: products.csv
Искусственно сгенерированные чеки онлайн‑покупок

### Столбцы:
- **purchase_id** (UUID) — уникальный идентификатор чека
- **person_id** (UUID) — уникальный идентификатор пользователя
- **gender** (string) — пол пользователя (`m` или `f`)
- **tariff** (string) — тариф (одно из 7 значений):
  - hard
  - harder
  - best
  - bester
  - fast
  - faster
- **transaction_type** (string) — тариф (одно из 4 значений):
  - drinks
  - travel
  - cars
  - food
- **purchase_amount** (numeric) — сумма покупки
- **purchase_date** (date) — дата покупки
- **birth_date** (date) — дата рождения пользователя
- **age_at_purchase** (integer) — возраст пользователя на момент покупки (в годах)
