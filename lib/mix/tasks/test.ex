defmodule Mix.Tasks.Porta.Test do
  use Mix.Task

  import Macro, only: [underscore: 1]
  import Mix.Generator

  def run(args) do
    Mix.Tasks.run "ecto.reset", []
	Mix.Tasks.run "test", args
  end
end
