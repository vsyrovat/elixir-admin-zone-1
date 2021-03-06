defmodule App.AuthTest do
  # use App.DataCase, async: true
  use AppWeb.ConnCase, async: true
  use Bamboo.Test
  alias App.Auth
  alias App.Auth.User

  describe "users" do
    alias App.Auth.User

    @valid_attrs %{
      email: "some email",
      is_admin: true,
      name: "some name",
      password: "some password"
    }
    @update_attrs %{
      email: "some updated email",
      is_admin: false,
      name: "some updated name"
    }
    @invalid_attrs %{email: nil, is_admin: nil, name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.is_admin == true
      assert user.name == "some name"
      assert user.password == nil
      assert User.checkpwd("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.is_admin == false
      assert user.name == "some updated name"
      assert User.checkpwd("some password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end

    test "delivery mail delivers mail" do
      user = user_fixture()
      conn = get(build_conn(), "/")
      expected_email = App.Auth.email_password_recovery(conn, user)
      assert_delivered_email(expected_email)
    end
  end
end
