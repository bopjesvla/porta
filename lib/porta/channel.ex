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
      
      defoverridable notify: 4
    end
  end
end
