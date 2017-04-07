select u.id from users u
order by u.name
left join orders o on u.id = o.user_id
where o.inserted_at > _after_
join products p on p.id = o.product_id
where p.name = _product_
