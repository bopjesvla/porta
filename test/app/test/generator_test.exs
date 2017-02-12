defmodule App.GeneratorTest do
  use ExUnit.Case
  alias Mix.Tasks

  # test "gen.migration, single query" do
  #   :ok = Ecto.Adapters.SQL.Sandbox.checkout(App.Repo)
  #   File.rm_rf("priv/repo/migrations")
  #   File.rm_rf!("sql/migrations")
  #   rnd = :rand.uniform 99999999999
  #   name = "mig"
  #   path = "sql/migrations/#{name}.sql"
  #   assert File.exists?(path)
  #   File.write path, "create or replace function migration_name() returns integer as 'select 5 as rnd' language sql"
  #   Tasks.Ecto.Migrate.run []
  #   assert %{rnd: rnd} = App.Repo.query!("select migration_name()")
  # end
end
