defmodule App.Repo.Migrations.SqlTrigger do
  use Ecto.Migration

  def change do
    "priv/triggers/**/*.sql"
    |> Path.wildcard
    |> Enum.map(&File.read!/1)
    |> Enum.flat_map(&String.split(&1, ~r/\n\s*-----.*/, trim: true))
    |> Enum.each(&execute/1)

  end
end
