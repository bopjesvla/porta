# Porta

## Composable SQL

An example:

__priv/queries/banned_by_occupation.sql__ 

```sql
select u.* from users u
where u.banned = true and u.occupation = _occupation_
order by u.age
```

__priv/queries/bought_product_after.sql__ 

```sql
select u.id from users u
order by u.name
left join orders o on u.id = o.user_id
where o.inserted_at > _after_
join products p on p.id = o.product_id
where p.name = _product_
```

__lib/app/repo.ex__

```elixir
defmodule App.Repo do
  use Ecto.Repo
  use Porta.Repo
  
  def 
end

list_of_maps_containing_banned_cheerleaders_who_bought_salmon_after_article_50_was_invoked =
  App.Repo.run! [
    banned_by_occupation: %{occupation: "cheerleader"},
    bought_product_after: %{product: "salmon", after: ~N"2017-03-29 12:30:00"}
  ]
```

Runs something equivalent to:

```sql
select u.* from users u
left join orders o on u.id = o.user_id
join products p on p.id = o.product_id
where u.banned = true and u.occupation = $1
  and o.inserted_at > $2 and p.name = _product_
order by u.age, u.name
```

With the positional arguments: `["cheerleader", ~N"2017-03-29 12:30:00")]`

### Caveats

The merger above is less intelligent than it seems.

It first breaks up each query wherever a line starts with a clause keyword such as `left join`, `where` and `order by`. Because of this, the newlines in the examples above are required.  After that, it replaces all named parameters with positional parameters (or subqueries, or raw SQL). Then it groups and sorts all clauses on their type, maintaining the order of clauses of the same type. Finally, clauses of the same type are merged together if necessary. 

While this approach supports all SQL dialects and allows for more expressive queries than the typical ORM, there are a few problems:

- Each table has to be aliased the same way across all merged queries. There are ways around this so I'm not sure how big of a problem this is going to be.
- Some clause types do not have a simple, natural merge strategy. In the case of `select`s, this means we currently discard everything but the first one.

### Subqueries

Whenever a keyword list is used in place of an argument, it is assumed to be a subquery:

### Raw SQL

(don't put user input in raw parameters)

To insert raw SQL in the place of a named parameter, use a {:raw, param} tuple:

## SQL Migrations

## Installation

Most of Porta's features require a somewhat recent version of Ecto. Some require Phoenix. Other than that:

```elixir
def deps do
  [{:porta, "~> 0.2.0"}]
end
```

