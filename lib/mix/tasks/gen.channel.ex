defmodule Mix.Tasks.Porta.Gen.Channel do
  use Mix.Task

  import Macro, only: [underscore: 1]
  import Mix.Generator
  
  def run(args) do
    case OptionParser.parse(args) do
      {_opts, [name, model], _} ->
        # migration_args = args ++ ["--change", sql_template(path(name))]
        # Mix.Task.run("ecto.gen.migration", migration_args)
        create_directory "web/channels"
        create_file path(name), """
        
        """
      {_, _, _} ->
        Mix.raise "expected porta.gen.migration to receive the migration file name, " <>
                  "got: #{inspect Enum.join(args, " ")}"
    end
  end

  def path(name), do: "web/channels/#{underscore(name)}.sql"
end