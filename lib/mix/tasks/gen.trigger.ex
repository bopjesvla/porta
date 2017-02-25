defmodule Mix.Tasks.Porta.Gen.Trigger do
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
        {_, [name, table], _} ->
          fullname = "#{table}_#{underscore(name)}"

          path = "sql/triggers/#{fullname}.sql"
          create_directory "sql/triggers"

          create_file path, """
            create or replace function #{fullname}() returns trigger as $$
            declare
              data json;
              latest record;
              notification text;
            begin
              latest = case TG_OP
                when 'DELETE' then OLD
                else NEW
              end;
              data = row_to_json(latest);
              notification = json_build_object(
                'table', TG_TABLE_NAME,
                'event', lower(TG_OP),
                'data', data
              );
              perform pg_notify('#{table}', notification::text);
              return null;
            end
            $$ language plpgsql;

            ----- keep this divider

            drop trigger if exists #{fullname}_trigger on #{table};

            ----- keep this divider

            create trigger #{fullname}_trigger
            after insert or update or delete on #{table}
            for each row execute procedure #{fullname}();
          """
        {_, _, _} ->
          Mix.raise "expected to receive the table and trigger names, " <>
                    "got: #{inspect Enum.join(args, " ")}"
        end
  end
end
