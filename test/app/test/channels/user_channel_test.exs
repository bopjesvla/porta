defmodule App.UserChannelTest do
  use App.ChannelCase

  alias App.UserChannel
  alias App.User

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(UserChannel, "users")

    {:ok, socket: socket}
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push socket, "ping", %{"hello" => "there"}
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end

  test "notified of inserts", %{socket: socket} do
    Repo.insert! %User{name: "x"}
    assert_push "notif", %{"data" => %{"name" => "x"}, "event" => "insert"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
