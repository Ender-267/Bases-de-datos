WITH VentasPorVariedad AS (
    SELECT P.varietal,
           COUNT(DISTINCT OC.username) AS total_compradores,
           SUM(CL.quantity) AS total_unidades_vendidas,
           SUM(CL.quantity * R.price) AS ingreso_total,
           AVG(CL.quantity) AS promedio_unidades_por_referencia,
           COUNT(DISTINCT CASE WHEN OC.country IS NOT NULL THEN OC.country END) AS paises_consumidores_potenciales
    FROM Orders_Clients OC
    JOIN Client_Lines CL ON OC.orderdate = CL.orderdate
    JOIN References R ON CL.barcode = R.barcode
    JOIN Products P ON R.product = P.product
    WHERE EXTRACT(YEAR FROM OC.orderdate) = EXTRACT(YEAR FROM SYSDATE) - 1
    GROUP BY P.varietal
)
SELECT varietal,
       total_compradores,
       total_unidades_vendidas,
       ingreso_total,
       promedio_unidades_por_referencia,
       paises_consumidores_potenciales
FROM VentasPorVariedad
ORDER BY total_unidades_vendidas DESC
FETCH FIRST ROW ONLY;
