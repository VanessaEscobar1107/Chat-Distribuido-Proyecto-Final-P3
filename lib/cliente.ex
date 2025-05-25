defmodule ChatApp.Cliente do
  use GenServer

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, any()}
 def start_link(usuario) do
  GenServer.start_link(__MODULE__, usuario, name: {:via, Registry, {ChatRegistry, usuario}})
end

def init(usuario) do
  # Attempt to register the user in the Registry
  case Registry.register(ChatRegistry, usuario, self()) do
    {:ok, _} ->
      IO.puts("Cliente #{usuario} iniciado y registrado en el registro.")
      {:ok, usuario}

    {:error, {:already_registered, _}} ->
      IO.puts("El cliente #{usuario} ya está registrado.")
      {:stop, :already_registered}
  end
end


  def handle_cast({:nuevo_mensaje, mensaje}, usuario) do
    IO.puts("[Mensaje] #{mensaje}")
    {:noreply, usuario}
  end
end
