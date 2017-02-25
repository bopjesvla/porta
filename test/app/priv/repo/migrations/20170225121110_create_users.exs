defmodule App.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
"sql/migrations/create_users.sql"
|> File.read!
|> String.split(~r/
 *-----.*/, trim: true)
|> Enum.each(&execute/1)

  end
end
