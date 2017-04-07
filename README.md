# Porta

Porta is an extension of Ecto (and, optionally, Phoenix) which provides an alternative, more SQL-oriented way of doing database stuff. Its most notable feature is Composable SQL. An example:

*priv/queries/banned_users_by_occupation.sql* 

```sql
select u.* from users u
where u.banned = true and u.occupation = _occupation_
order by u.age
```

*priv/queries/users_bought_product_after.sql* 

```sql
select u.id from users u
order by u.name
left join orders o on u.id = o.user_id
where o.inserted_at > _after_
join products p on p.id = o.product_id
where p.name = _product_
```

*lib/app/repo.ex*

```elixir
defmodule App.Repo do
  use Ecto.Repo
  use Porta.Repo
  
  def 
end

banned_cheerleaders_who_bought_salmon_after_article_50_was_invoked =
  App.Repo.run! [
    banned_users_by_occupation: %{occupation: "cheerleader"},
    users_bought_product_after: %{product: "salmon", after: ~N"2017-03-29 12:30:00"}
  ]
```

This merges the two queries and runs something equivalent to:

```sql
select u.* from users u
left join orders o on u.id = o.user_id
join products p on p.id = o.product_id
where u.banned = true and u.occupation = $1
  and o.inserted_at > $3 and p.name = $2
order by u.age, u.name
```

With the positional arguments `["cheerleader", "salmon", ~N"2017-03-29 12:30:00"]`.

## Caveats

The merger above is less intelligent than it seems.

It first breaks up each query wherever a line starts with a clause keyword such as `left join`, `where` and `order by`. Because of this, the **newlines in the examples above are required**.  After that, it replaces all named parameters with positional parameters (or subqueries, or raw SQL). Then it groups and sorts all clauses on their type, maintaining the order of clauses of the same type. Finally, clauses of the same type are merged together if necessary. 

While this approach supports all SQL dialects and allows for more expressive queries than most typical ORMs, there are a few problems:

- Each table has to be aliased the same way across all merged queries. I think this can always be acheived through subquerying, but I may be wrong.
- Some clause types do not have a simple, natural merge strategy. In the case of `select` clauses, this means we currently discard everything but the first one.

## Subqueries

Whenever a keyword list is used in place of an argument, it is assumed to be a subquery:

```elixir
users_who_bought_user_9s_favorite_product_after_carnaval_in_the_year_1979 =
  Repo.run! users_bought_product_after: %{
    product: [favorite_product: %{user_id: 9}],
    after: [carnaval: %{year: 1979}]
  }
```

In this example, `priv/queries/favorite_product.sql` and `priv/queries/carnaval.sql` respectively contain queries returning a user's favorite product and the date of carnaval in a given year.

## Raw SQL

(don't put user input in raw parameters or you will get hacked and robbed and lynched)

To insert raw SQL in the place of a named parameter, use a {:raw, param} tuple. This can be used to dynamically specify columns and table names:

*priv/queries/select_user_column.sql*

```sql
select _column_ from users
```

```elixir
Repo.run! select_user_column: {:raw, "name"}
```

## Ad-Hoc Queries

A few SQL queries are included in Porta by default. An example is the `select` query, which works as if you put `select _columns_ from _from_ _alias_` in `priv/queries/select.sql`. These queries can be composed as well:

```elixir
Repo.run! [
  union_all: %{
    left: [
      select: %{
        columns: {:raw, "name"},
        from: [banned_users_by_occupation: %{occupation: "guru"}],
        alias: {:raw, "gurus"}
      }
    ],
    right: [
      select: %{
        columns: {:raw, "name"},
        from: {:raw, "users"},
        alias: {:raw, "u"}
      },
      where: %{clause: {:raw, "u.age < 19"}}
    ]
  },
  order: %{by: {:raw, "name"}}
]
```

However, the SQL-file equivalent is usually more readable and flexible.

A thing that should see even rarer use is the ability to replace the atoms in the query list with strings:

```sql
Repo.run! [{"select _i_ - 5", %{i: 6}}]
```

This is equivalent to putting `select _i_ - 5` in `select_i_minus_5.sql` and running:

```sql
Repo.run! select_i_minus_5: %{i: 6}
```

## SQL Files as Migrations

I'll write up documentation for this and the other Mix tasks someday.

## Installation

Most of Porta's features require a somewhat recent version of Ecto. Some require Phoenix. Other than that:

```elixir
def deps do
  [{:porta, "~> 0.2.0"}]
end
```

