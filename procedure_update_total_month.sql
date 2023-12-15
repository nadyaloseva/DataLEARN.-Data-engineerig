-- добавление в таблицу агрегированных значений за последний месяц
CREATE OR REPLACE PROCEDURE public.update_total_month()
 LANGUAGE plpgsql
AS $procedure$
declare 
    v_date date;
begin 

	insert into dw.total_month(type,month_date,sales,quantity,discount,profit)
	select 'fact_profit' as type,
	       DATE_TRUNC('month',order_date)::date,
	       SUM(sales) as sales,
	       SUM(quantity) as quantity,
	       SUM(discount) as discount,
	       sum(profit) as profit
	  from stg.v_all_orders 
	where 
	  DATE_TRUNC('month',order_date) = (select DATE_TRUNC('month',order_date) 
	                                        from stg.v_all_orders order by order_date desc limit 1)::date
	  and order_id not in (select order_id 
	                           from stg.v_all_orders where returned = 'Yes')
	group by DATE_TRUNC('month',order_date);

	insert into dw.total_month(type,month_date,sales,quantity,discount,profit)
	select 'fact_return_profit' as type,
	       DATE_TRUNC('month',order_date)::date,
	       SUM(sales) as sales,
	       SUM(quantity) as quantity,
	       SUM(discount) as discount,
	       sum(profit) as profit
	  from stg.v_all_orders 
	where 
	  DATE_TRUNC('month',order_date) = (select DATE_TRUNC('month',order_date) 
	                                        from stg.v_all_orders order by order_date desc limit 1)::date
	  and order_id in (select order_id 
	                           from stg.v_all_orders where returned = 'Yes')
	group by DATE_TRUNC('month',order_date);

end;
$procedure$
;