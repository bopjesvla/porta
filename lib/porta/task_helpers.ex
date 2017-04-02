defmodule Porta.TaskHelpers do
  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Generator

  # def sql_migration(args, path_fn, content_fn \\ fn _ -> "" end) do
  #   case OptionParser.parse(args) do
  #     {opts, [name], _} ->
  #       path = path_fn(name)
  #
  #       migration_args = args ++ ["--change", sql_template(path)]
  #       Mix.Task.run("ecto.gen.migration", migration_args)
  #       create_directory "priv/sql_migrations"
  #       create_file path, content_fn(name)
  #     {_, _, _} ->
  #       Mix.raise "expected to receive the migration file name, " <>
  #                 "got: #{inspect Enum.join(args, " ")}"
  #   end
  # end

  def sql_template(path) do
    """
    "#{path}"
    |> File.read!
    |> String.split(~r/\n\s*-----.*/, trim: true)
    |> Enum.each(&execute/1)
    """
  end
end
