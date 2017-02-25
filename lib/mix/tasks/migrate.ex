defmodule Mix.Tasks.Porta.Migrate do
  def run(args) do
    Mix.Task.run "app.start", []
    Enum.each Mix.Ecto.parse_repo(args), fn repo ->
      Mix.Ecto.migrations_path(repo)
      |> Path.join("*_sql_trigger.exs")
      |> Path.wildcard
      |> case do
        [file] ->
          dest = String.replace(file, ~r|/\d{12,}|,  "/#{timestamp()}")
          File.rename file, dest
        [] ->
          Mix.Task.run "ecto.gen.migration", ["sql_trigger", "--change", """
          "sql/triggers/**/*.sql"
          |> Path.wildcard
          |> Enum.map(&File.read!/1)
          |> Enum.flat_map(&String.split(&1, ~r/\n\s*-----.*/, trim: true))
          |> Enum.each(&execute/1)
          """]
      end
    end
    Mix.Task.run "ecto.migrate", args
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
