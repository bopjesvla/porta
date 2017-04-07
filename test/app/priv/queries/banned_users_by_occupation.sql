select u.* from users u
where u.banned = true and u.occupation = _occupation_
order by u.age
