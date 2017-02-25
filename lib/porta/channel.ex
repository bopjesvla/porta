defmodule Porta.Channel do
  defmacro __using__(_) do
    quote do
      import Postgrex.Notifications, only: [
        listen: 2, unlisten: 2, listen!: 2, unlisten!: 2,
        listen: 3, unlisten: 3, listen!: 3, unlisten!: 3
      ]
      
      def handle_info({:notification, pid, ref, channel, payload}, socket) do
        msg = case Poison.decode(payload) do
          {:ok, msg} -> msg
          {:error, _} -> payload
        end
        
        notify(channel, msg, %{pid: pid, ref: ref}, socket)
      end
      
      def notify(channel, msg, _, socket) do
        raise "Unhandled notification from #{channel}: #{inspect msg}"
      end
      
      def tables(queries_and_names) do
        tablelist = Enum.map queries_and_names, fn q_or_n ->
          case q_or_n do
            n when is_binary(n) ->
              %{name: n, data: []}
            %Ecto.Query{} = q ->
              %{name: "users", data: Repo.all(q)}
            table -> table
          end
        end
        %{tables: tablelist}
      end
      
      def table(arg) do
        tables([arg])
      end
      
      defoverridable notify: 4
    end
  end
end
