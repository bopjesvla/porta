defmodule Mix.Tasks.Porta.Gen.Migration do
  use Mix.Task

  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Generator

  @shortdoc "Generates a new migration for the repo"

  @moduledoc """
  Generates a migration.
  The repository must be set under `:ecto_repos` in the
  current app configuration or given via the `-r` option.
  ## Examples
      mix ecto.gen.migration add_posts_table
      mix ecto.gen.migration add_posts_table -r Custom.Repo
  By default, the migration will be generated to the
  "priv/YOUR_REPO/migrations" directory of the current application
  but it can be configured to be any subdirectory of `priv` by
  specifying the `:priv` key under the repository configuration.
  This generator will automatically open the generated file if
  you have `ECTO_EDITOR` set in your environment variable.
  ## Command line options
    * `-r`, `--repo` - the repo to generate migration for
  """

  @doc false
  def run(args) do
    case OptionParser.parse(args) do
        {opts, [name], _} ->
          migration_args = args ++ ["--change", sql_template(path(name))]
          Mix.Task.run("ecto.gen.migration", migration_args)
          create_directory "sql/migrations"
          create_file path(name)
        {_, _, _} ->
          Mix.raise "expected porta.gen.migration to receive the migration file name, " <>
                    "got: #{inspect Enum.join(args, " ")}"
        end
  end

  def path(name), do: "sql/migrations/#{underscore(name)}"

  def sql_template(path) do
    """
    "#{path}"
    |> File.read!
    |> String.split("\\n-----")
    |> Enum.each(&execute/1)
    """
  end
end
