-- (Query 1) Revenue, leads, Conversion and Average Tickets month by month
-- Columns: month, leads (#), sales (#), revenue (k, R$), conversion (%), average ticket (k, R$)

WITH
	leads AS(
		--Months, Leads
		SELECT
		DATE_TRUNC('month', visit_page_date)::date AS visit_page_month,
		COUNT (*) AS visit_page_count
	FROM sales.funnel
	GROUP BY visit_page_month
	ORDER BY visit_page_month
	
	),
	
	payments AS (
		--Sales/Revenue
		SELECT 
			DATE_TRUNC('month', fun.paid_date)::date AS paid_month,
			COUNT(fun.paid_date) AS paid_count,
			SUM(pro.price * (1 + fun.discount)) AS revenue
		FROM sales.funnel as fun
		LEFT JOIN sales.products as pro
			ON fun.product_id = pro.product_id
		WHERE fun.paid_date IS NOT NULL
		GROUP BY paid_month
		ORDER BY paid_month
	)

--Conversion into Sale, Average Ticket
SELECT
	leads.visit_page_month AS "month",
	leads.visit_page_count AS "leads",
	payments.paid_count AS "sales",
	(payments.revenue/1000) AS "revenue (k, R$)",
	(payments.paid_count::float/leads.visit_page_count::float) AS "conversion (%)",
	(payments.revenue/payments.paid_count/1000) AS "average ticket (k, R$)"
FROM leads
LEFT JOIN payments
	ON leads.visit_page_month = paid_month

-- (Query 2) Best Selling Brands
-- Columns: brand, sales

SELECT
	pro.brand AS marca,
	COUNT(fun.paid_date) AS "vendas (#)"
FROM sales.funnel AS fun
LEFT JOIN sales.products AS pro
	ON fun.product_id = pro.product_id
WHERE paid_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY marca
ORDER BY "vendas (#)" DESC
LIMIT 5

-- (Query 3) Best Selling Stores
-- Columns: store, sales (#)

SELECT
	sto.store_name AS store,
	COUNT(fun.paid_date) AS "sales"
FROM sales.funnel AS fun
LEFT JOIN sales.stores AS sto
	ON fun.store_id = sto.store_id
WHERE paid_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY store
ORDER BY "sales" DESC
LIMIT 5

-- (Query 4) Days of the Week with the Highest Number of Visits in the Website
-- Columns: day_week(int), day of week(varchar), visits (#)

SELECT
	EXTRACT('dow' FROM visit_page_date) AS day_week,
	CASE
		WHEN EXTRACT('dow' FROM visit_page_date) = 0 then 'sunday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 1 then 'monday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 2 then 'tuesday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 3 then 'wednesday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 4 then 'thursday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 5 then 'friday'
		WHEN EXTRACT('dow' FROM visit_page_date) = 6 then 'saturday'
		ELSE NULL 
		END AS "day of week",		
	COUNT(*) AS "visits"
FROM sales.funnel
WHERE visit_page_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY day_week
ORDER BY day_week
