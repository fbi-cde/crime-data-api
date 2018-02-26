CREATE MATERIALIZED VIEW summarized_arson_data_national AS
select a.data_year as data_year,
  SUM(a.sum_ars_cleared) as arson_cleared,
  SUM(a.sum_ars_actual) as arson_actual
   (((((SUM(a.sum_ars_actual))) *1.0)/ (SUM(CASE WHEN month_num = 12 THEN (SUM(CASE WHEN month_num = 12 THEN population ELSE 0 END)) ELSE null END) )*1.0) * 100000.0) as arson_rate,
from public.summarized_data a  GROUP BY data_year;
