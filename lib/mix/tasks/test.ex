defmodule Mix.Tasks.Porta.Test do
  use Mix.Task

  @preferred_cli_env :test

  def run(args) do
    Mix.Tasks.Ecto.Drop.run []
    Mix.Tasks.Ecto.Create.run []
    Mix.Tasks.Ecto.Migrate.run []
    Mix.Tasks.Test.run args
  end
end
