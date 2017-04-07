select p.name from products p
join orders o on p.id = o.product_id
join users u on u.id = o.user_id
where u.id = _user_id_
group by p.id
order by count(o.*)
limit 1
