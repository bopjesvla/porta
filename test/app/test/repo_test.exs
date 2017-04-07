defmodule App.RepoTest do
  use App.ModelCase

  @moduletag :repo

  # test "run!" do
  #   assert [%{"rnd" => 5}] == Repo.run! "select 5 as rnd"
  # end
  # test "run" do
  #   assert {:ok, [%{"rnd" => 5}]} == Repo.run "select 5 as rnd"
  # end
  test "run! from file" do
    assert [%{"five" => %{"five" => 5}}] == Repo.run! select5: []
  end
  test "run! from file with parameters" do
    assert [%{"i" => 4}] == Repo.run! select_int: %{param: 4}
  end
  test "run! from file with subqueries" do
    assert [%{"i" => 6}] == Repo.run! select_int: %{param: [select_int: [param: 6]]}
  end
  test "run! scrambled query" do
    assert [%{"i" => 6}, %{"i" => 2}] == Repo.run! scrambled: %{
      mod: 2, excluded: 4, similar_to: 5
    }
  end
  test "run! merged query" do
    assert [%{"i" => 2}] == Repo.run! [
      scrambled: %{mod: 2, excluded: 4, similar_to: 5},
      scrambled: %{mod: 2, excluded: 6, similar_to: 5}
    ]
  end
  test "run! example queries" do
    Repo.run! [{"create table users(id serial primary key, age int, banned boolean, name text, occupation text)", []}]
    Repo.run! [{"create table orders(user_id int, product_id int, inserted_at timestamp)", []}]
    Repo.run! [{"create table products(id serial primary key, name text)", []}]

    Repo.run! [
      banned_users_by_occupation: %{occupation: "cheerleader"},
      users_bought_product_after: %{product: "salmon", after: ~N"2017-03-29 12:30:00"}
    ]

    Repo.run! users_bought_product_after: %{
      product: [favorite_product: %{user_id: 9}],
      after: [carnaval: %{year: 1979}]
    }
    Repo.run! select_user_column: %{
      column: {:raw, "name"}
    }
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
  end
end
