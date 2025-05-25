defmodule ChatApp.Repo.Migrations.AddConnectedUsers do
  use Ecto.Migration

  def change do
    create table(:connected_users) do
      add :username, :string, null: false
      add :room, :string, null: false
      timestamps()
    end

    create unique_index(:connected_users, [:username, :room])
  end
end
