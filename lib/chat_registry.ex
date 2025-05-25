defmodule ChatRegistry do
  use GenServer

  def start_link(_) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end
end
