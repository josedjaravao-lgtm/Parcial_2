Code.require_file("parser.exs", __DIR__)
Code.require_file("util.exs", __DIR__)

defmodule Coordinador do
  @doc """
  Inicia dos procesos concurrentes para leer ciudades y movimientos.
  """
  def leer_archivos_concurrentes(ruta_ciudades, ruta_movimientos) do
    coordinador_pid = self()

    # Proceso Trabajador 1: Ciudades
    spawn(fn ->
      leer_y_enviar(coordinador_pid, :ciudades, ruta_ciudades)
    end)

    # Proceso Trabajador 2: Movimientos
    spawn(fn ->
      leer_y_enviar(coordinador_pid, :movimientos, ruta_movimientos)
    end)

    # El coordinador espera ambos resultados en cualquier orden
    esperar_respuestas(%{ciudades: nil, movimientos: nil})
  end

  defp leer_y_enviar(coordinador_pid, tipo, ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n")

        resultado =
          if tipo == :ciudades do
            Parser.procesar_ciudades(lineas)
          else
            Parser.procesar_movimientos(lineas)
          end

        send(coordinador_pid, {:exito, tipo, resultado})

      {:error, razon} ->
        send(coordinador_pid, {:error_lectura, tipo, razon})
    end
  end

  # Recompilador de respuestas (Recibe mensajes en cualquier orden)
  defp esperar_respuestas(%{ciudades: c, movimientos: m}) when not is_nil(c) and not is_nil(m) do
    {:ok, c, m}
  end

  defp esperar_respuestas(estado) do
    receive do
      {:exito, :ciudades, datos} ->
        esperar_respuestas(Map.put(estado, :ciudades, {:ok, datos}))

      {:exito, :movimientos, datos} ->
        esperar_respuestas(Map.put(estado, :movimientos, {:ok, datos}))

      {:error_lectura, tipo, razon} ->
        esperar_respuestas(Map.put(estado, tipo, {:error, razon}))
    after
      5000 ->
        {:error, :timeout}
    end
  end
end
