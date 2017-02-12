defmodule Porta.Repo do
  defmacro __using__(_opts \\ []) do
    quote do
      def run(q, params \\ [], opts \\ []) do
		query = if is_atom(q) do
		  File.read! "sql/queries/#{q}.sql"
        else
		  q
        end

	    case Ecto.Adapters.SQL.query(__MODULE__, query, params, opts) do
		  {:ok, %{columns: columns, rows: rows}} ->
		    maps = Enum.map rows, &(Enum.zip(columns, &1) |> Enum.into(%{}))
			{:ok, maps}
		  res ->
		    res
		end
      end

      def run!(q, params \\ [], opts \\ []) do
		query = if is_atom(q) do
		  File.read! "sql/queries/#{q}.sql"
        else
		  q
        end

	    case Ecto.Adapters.SQL.query!(__MODULE__, query, params, opts) do
		  %{columns: columns, rows: rows} ->
		    Enum.map rows, &(Enum.zip(columns, &1) |> Enum.into(%{}))
		  res ->
		    res
		end
      end
	end
  end
end
