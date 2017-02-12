defmodule App.RepoTest do
  use App.ModelCase

  test "run!" do
    assert [%{"rnd" => 5}] == Repo.run! "select 5 as rnd"
  end
  test "run" do
    assert {:ok, [%{"rnd" => 5}]} == Repo.run "select 5 as rnd"
  end
  test "run! from file" do
    assert [%{"five" => %{"five" => 5}}] == Repo.run! :select5
  end
end
