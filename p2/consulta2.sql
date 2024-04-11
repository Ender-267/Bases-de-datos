WITH VentasMensuales AS (
    SELECT TO_CHAR(OC.orderdate, 'YYYY-MM') AS mes,
           R.product AS referencia_mas_vendida,
           COUNT(DISTINCT OC.username || OC.orderdate) AS num_pedidos,
           SUM(CL.quantity) AS total_unidades_vendidas,
           SUM(CL.quantity * R.price) AS ingreso_total,
           SUM(CL.quantity * (R.price - SL.cost)) AS beneficio_total,
           ROW_NUMBER() OVER (PARTITION BY TO_CHAR(OC.orderdate, 'YYYY-MM') ORDER BY SUM(CL.quantity) DESC) AS rn
    FROM Orders_Clients OC
    JOIN Client_Lines CL ON OC.orderdate = CL.orderdate
    JOIN References R ON CL.barcode = R.barcode
    JOIN Supply_Lines SL ON CL.barcode = SL.barcode
    WHERE OC.orderdate >= ADD_MONTHS(TRUNC(SYSDATE, 'MONTH'), -12)
    GROUP BY TO_CHAR(OC.orderdate, 'YYYY-MM'), R.product
)
SELECT mes,
       referencia_mas_vendida,
       num_pedidos,
       total_unidades_vendidas,
       ingreso_total,
       beneficio_total
FROM VentasMensuales
WHERE rn = 1
ORDER BY TO_DATE(mes, 'YYYY-MM');
