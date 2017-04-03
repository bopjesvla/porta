order by abs(i - _similar_to_)
where i % _mod_ = 0
and i != _excluded_
select * from generate_series(1, 7) s(i)
