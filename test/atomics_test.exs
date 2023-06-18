defmodule AshPostgres.AtomicsTest do
  use AshPostgres.RepoCase, async: false
  alias AshPostgres.Test.{Api, Post}

  require Ash.Atomic

  test "a basic atomic works" do
    post =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "foo", price: 1})
      |> Api.create!()

    atomic = Ash.Atomic.atomic(:price, price + 1)

    assert %{price: 2} =
             post
             |> Ash.Changeset.for_update(:update, %{})
             |> Ash.Changeset.atomic(atomic)
             |> Api.update!()
  end

  test "an atomic that violates a constraint will return the proper error" do
    post =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "foo", price: 1})
      |> Api.create!()

    organization_id = Ash.UUID.generate()

    atomic = Ash.Atomic.atomic(:organization_id, ^organization_id)

    assert_raise Ash.Error.Invalid, ~r/does not exist/, fn ->
      post
      |> Ash.Changeset.for_update(:update, %{})
      |> Ash.Changeset.atomic(atomic)
      |> Api.update!()
    end
  end
end
