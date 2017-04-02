defmodule App.RepoTest do
  use App.ModelCase

  @moduletag :repo

  # test "run!" do
  #   assert [%{"rnd" => 5}] == Repo.run! "select 5 as rnd"
  # end
  # test "run" do
  #   assert {:ok, [%{"rnd" => 5}]} == Repo.run "select 5 as rnd"
  # end
  test "run! from file" do
    assert [%{"five" => %{"five" => 5}}] == Repo.run! select5: []
  end
  test "run! from file with parameters" do
    assert [%{"i" => 4}] == Repo.run! select_int: %{param: 4}
  end
  test "run! from file with subqueries" do
    assert [%{"i" => 6}] == Repo.run! select_int: %{param: [select_int: [param: 6]]}
  end
end
