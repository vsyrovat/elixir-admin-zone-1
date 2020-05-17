defmodule App.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Auth.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    User.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_user!(attrs \\ %{}) do
    {:ok, user} = create_user(attrs)
    user
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def find_admins do
    query =
      from u in User,
        where: u.is_admin == true,
        select: u

    Repo.all(query)
  end

  @spec find_user_by_email(String.t()) :: User.t() | nil
  def find_user_by_email(email) do
    query =
      from u in User,
        where: u.email == ^email,
        select: u

    Repo.one(query)
  end

  def email_password_recovery(conn, %User{} = user) do
    key = random_string(32)
    {:ok, user} = update_user(user, %{password_recovery_key: key})

    App.Email.password_recovery_email(conn, user)
    |> App.Mailer.deliver_later()
  end

  def random_string(len) do
    :crypto.strong_rand_bytes(len) |> Base.url_encode64() |> binary_part(0, len)
  end
end
