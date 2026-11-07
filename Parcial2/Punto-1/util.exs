defmodule Util do
  @moduledoc """
  Módulo de funciones auxiliares de formato, impresión y validación.
  """

  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  def ingresar_texto(mensaje) do
    mensaje
    |> IO.gets()
    |> to_string()
    |> String.trim()
  end

  @doc """
  Formatea un número flotante a 2 cifras decimales como String.
  Ejemplo: 14.0 -> "14.00"
  """
  def formatear_decimal(numero) when is_number(numero) do
    :erlang.float_to_binary(numero * 1.0, [decimals: 2])
  end

  def formatear_decimal(_), do: "No aplica"

  @doc """
  Verifica si una cadena de texto no está vacía tras limpiar espacios.
  """
  def texto_valido?(str) when is_binary(str) do
    String.trim(str) != ""
  end

  def texto_valido?(_), do: false
end
