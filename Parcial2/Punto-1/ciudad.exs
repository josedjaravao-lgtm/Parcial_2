defmodule Ciudad do
  @enforce_keys [:id_ciudad, :nombre, :numero_habitantes]
  defstruct [:id_ciudad, :nombre, :numero_habitantes]
end
