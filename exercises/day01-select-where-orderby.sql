SELECT 
    product_name,
    (unit_price - unit_cost) AS unit_margin,
    ((unit_price - unit_cost) / unit_price) * 100 AS margin_percentage
FROM products
WHERE ((unit_price - unit_cost) / unit_price) * 100 > 50
ORDER BY unit_margin DESC;