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
    {offset, params, query} = get_csql(q, 0)
    IO.inspect query
    
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
    pieces
  end

  def build_priority_list(pieces) do
    pieces
    |> Enum.chunk(2)
    |> Enum.map(fn [keyword, clause] ->
      priority = Map.get @priorities, String.downcase(keyword), nil
      {priority, keyword <> clause}
    end)
  end

  def remove_selects(list) do
    p = @priorities["select"]
    Enum.filter(list, fn
      {^p, _} -> false
      _ -> true
    end)
  end

  def preprepare(q_list, params, init_offset) do
    # len = length(params)
    # [first | pieces] = Regex.split(~r/\$\d+/, q, include_captures: true)
    # {params, {final_offset, query}} = pieces
    # |> Enum.chunk(2)
    # |> Enum.flat_map_reduce({init_offset, q}, fn ["$" <> int, text], {position, q} ->
    #   i = String.to_integer(int)
    #   if i > len do
    #     raise "$#{i} is out of bounds in #{inspect params}"
    #   end
    #   p = Enum.fetch!(params, i - 1)
    #   case p do
    #     [{a, q} | _] when is_atom(a) ->
    #       {new_offset, new_params, subq} = get_csql(p, position)
    #       {new_params, {new_offset, "(#{get_csql()})" <> text}}
    #     p ->
    #       {p, {position, "$#{init_offset + i}" <> text}}
    #   end
    # end)

    Enum.reduce params, {init_offset, [], q_list}, fn {name, param}, {position, remaining_params, q_list} ->
      {new_offset, new_params, replacement} =
        case param do
          [{a, _} | _] when is_atom(a) ->
            {new_offset, new_params, subq} = get_csql(param, position)
            {new_offset, new_params ++ remaining_params,  "(#{subq})"}
          p ->
            {position + 1, [p | remaining_params], "$#{position + 1}"}
        end
      param_regex = ~r/\b_#{name}\b/
      newq = Enum.map q_list, fn {priority, q} ->
        {priority, Regex.replace(param_regex, q, replacement)}
      end
      {new_offset, new_params, newq}
    end
    # increased_q = Regex.replace(~r/\$\d+/, q, fn "$" <> int ->
    #   i = String.to_integer(int)
    #   if i > len do
    #     raise "$#{i} is out of bounds in #{inspect params}"
    #   end
    #   p = Enum.fetch!(params, i - 1)
    #   case p do
    #     [{a, q} | _] when is_atom(a) ->
    #       {new_offset, new_params, subq} = get_csql(param, position)
    #       "(#{get_csql()})"
    #   end
    #   "$#{String.to_integer(int) + by}"
    # end)
    # {count, increased_q}
  end

  def retrieve_query(s) when is_atom(s) do
    b = "priv/queries/#{s}.sql"
    |> File.read!
  end

  def get_csql(qs, offset) do
    {q_list, {new_offset, params}} =
      Enum.map_reduce(qs, {offset, []}, fn {q, params}, {offset, prev_params} ->
        {new_offset, new_params, newq} =
          q |> retrieve_query |> split_query |> build_priority_list
          |> preprepare(params, offset)

        {newq, {new_offset, new_params ++ prev_params}}
      end)

    q_string = q_list
    |> Enum.concat
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", fn {_priority, clause} -> clause end)

    {new_offset, params, q_string}
  end

  def merge(old, new) do
    new = String.split(new, "\n") |> Enum.filter()
  end
end
