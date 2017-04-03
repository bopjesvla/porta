defmodule Porta.Repo do
  @priorities %{
    "with" => 0,
    "select" => 10, "from" => 20,
    "join" => 30, "left join" => 30, "inner join" => 30, "right join" => 30,
    "where" => 70, "group by" => 80, "having" => 90, "window" => 100,
    "order by" => 110, "limit" => 120, "offset" => 130,
    "fetch" => 140, "for" => 150
  }
  @keywords Map.keys(@priorities)
  @joins Enum.filter(@keywords, &(@priorities[&1] == @priorities["join"]))
  @regex Regex.compile!("(^|\n)(?<keywords>" <> Enum.join(@keywords, "|") <> ")\\b", "i")

  defmacro __using__(_opts \\ []) do
    quote do
      def run(q, opts \\ []) do
        Porta.Repo.do_run(__MODULE__, q, opts)
      end

      def run!(q, opts \\ []) do
        case Porta.Repo.do_run(__MODULE__, q, opts) do
          {:ok, res} -> res
          {:error, error} -> raise error
        end
      end
    end
  end

  def do_run(repo, q, opts) do
    {_offset, rev_params, query} = get_csql(q, 0)
    IO.inspect query

    params = Enum.reverse(rev_params)
    
    case Ecto.Adapters.SQL.query(repo, query, params, opts) do
      {:ok, %{columns: columns, rows: rows}} when is_list(rows) and is_list(columns) ->
        maps = Enum.map rows, &(Enum.zip(columns, &1) |> Enum.into(%{}))
        {:ok, maps}
      res ->
        res
    end
  end

  def split_query(string) do
    [first | pieces] = Regex.split(@regex, string, on: [:keywords], include_captures: true)
    if Regex.match?(~r/\S/, first) do
      IO.inspect first
      raise "expected #{inspect string} to start with one of #{inspect @keywords}"
    end
    Enum.chunk(pieces, 2)
  end

  def build_priority_list(pieces) do
    pieces
    |> Enum.map(fn [keyword, clause] ->
      priority = Map.get @priorities, String.downcase(keyword), nil
      {priority, keyword <> clause}
    end)
  end

  def filter_except_first(list, fun) do
    {before, x} = Enum.split_while(list, fun)
    {first_match, rest} = Enum.split(x, 1)
    before ++ first_match ++ Enum.filter(rest, fun)
  end

  def preprepare(q_list, params, init_offset) do
    Enum.reduce params, {init_offset, [], q_list}, fn {name, param}, {position, remaining_params, q_list} ->
      {new_offset, new_params, replacement} =
        case param do
          [{a, _} | _] when is_atom(a) ->
            {new_offset, new_params, subq} = get_csql(param, position)
            {new_offset, new_params ++ remaining_params,  "(#{subq})"}
          p ->
            {position + 1, [p | remaining_params], "$#{position + 1}"}
        end
      param_regex = ~r/\b_#{name}_\b/
      newq = Enum.map q_list, fn [priority, q] ->
        [priority, Regex.replace(param_regex, q, replacement)]
      end
      {new_offset, new_params, newq}
    end
  end

  def retrieve_query(s) when is_atom(s) do
    b = "priv/queries/#{s}.sql"
    |> File.read!
  end

  def get_csql(qs, offset) do
    select_priority = @priorities["select"]

    {q_list, {new_offset, params}} =
      Enum.map_reduce(qs, {offset, []}, fn {q, params}, {offset, prev_params} ->
        {new_offset, new_params, newq} =
          q |> retrieve_query |> split_query
          |> preprepare(params, offset)

        {newq, {new_offset, new_params ++ prev_params}}
      end)

    q_string = q_list
    |> Enum.concat
    |> Enum.group_by(fn [keyword, _clause] ->
      @priorities[keyword]
    end)
    |> Enum.sort_by(fn {priority, _group} -> priority end)
    |> Enum.map_join("\n", fn {_priority, group} -> merge(group) end)

    {new_offset, params, q_string}
  end

  def merge([["select", clause] | _]) do
    "select" <> clause
  end

  def merge([["where", _] | _] = wheres) do
    "where" <> Enum.map_join(wheres, "\nand ", fn [_, clause] -> clause end)
  end

  def merge([[join, _] | _] = clauses) when join in @joins do
    Enum.map_join(clauses, "\n", fn [keyword, clause] -> keyword <> clause end)
  end

  def merge([[first, _] | _] = clauses) do
    first <> Enum.map_join(clauses, ",\n", fn [_, clause] -> clause end)
  end
end
