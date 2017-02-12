defmodule App.GeneratorTest do
  use ExUnit.Case

  test "gen.migration, single query" do
    name = "mig#{:random.uniform 1}"
    Mix.Tasks.run "porta.gen.migration", [name]
	path = "sql/migrations/#{name}.sql"
	assert File.exists?(path)
	File.write path, "create table bla (id int)"
	Mix.Tasks.run "ecto.migrate", []
    Mafia.Repo.query! "select * from bla"
  end
end
