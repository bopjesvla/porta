defmodule App.Repo.Migrations.CreateTest do
  use Ecto.Migration

  def change do
    "priv/sql_migrations/create_test.sql"
    |> File.read!
    |> String.split(~r/\n\s*-----.*/, trim: true)
    |> Enum.each(&execute/1)

  end
end
