defmodule App.UserChannelTest do
  use App.ChannelCase

  alias App.UserChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(UserChannel, "user:lobby")

    {:ok, socket: socket}
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push socket, "ping", %{"hello" => "there"}
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end

  test "shout broadcasts to user:lobby", %{socket: socket} do
    Repo.insert_all "users", [%{name: "x"}]
    assert_push "insert", %{"data" => %{"name" => "x"}}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
