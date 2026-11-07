Code.require_file("util.exs", __DIR__)

defmodule Calculador do
  @doc """
  Filtra los movimientos cuyo id_ciudad exista en la lista de ciudades válidas.
  Retorna {movimientos_validos, cantidad_rechazados}
  """
  def filtrar_movimientos_por_ciudades(movimientos, ciudades) do
    ids_validos = MapSet.new(ciudades, fn c -> c.id_ciudad end)

    {validos, rechazados} =
      Enum.reduce(movimientos, {[], 0}, fn mov, {acc_validos, acc_rechazados} ->
        if MapSet.member?(ids_validos, mov.id_ciudad) do
          {[mov | acc_validos], acc_rechazados}
        else
          {acc_validos, acc_rechazados + 1}
        end
      end)

    {Enum.reverse(validos), rechazados}
  end

  @doc """
  Genera el reporte agrupado por ciudad.
  """
  def generar_estadisticas_globales(ciudades, movimientos) do
    movs_por_ciudad = Enum.group_by(movimientos, fn m -> m.id_ciudad end)

    Enum.map(ciudades, fn ciudad ->
      movs_ciudad = Map.get(movs_por_ciudad, ciudad.id_ciudad, [])
      estadisticas = calcular_estadisticas_ciudad(movs_ciudad)

      Map.merge(%{ciudad: ciudad, movimientos: movs_ciudad}, estadisticas)
    end)
  end

  @doc """
  Calcula estadísticas de los movimientos de UNA ciudad usando recursividad explícita.
  """
  def calcular_estadisticas_ciudad([]) do
    %{
      total: 0,
      max_movimiento: nil,
      promedio_profundidad: "No aplica"
    }
  end

  def calcular_estadisticas_ciudad(movimientos) do
    {total, max_mov, suma_prof} = procesar_recursivo(movimientos, 0, nil, 0.0)

    promedio = suma_prof / total

    %{
      total: total,
      max_movimiento: max_mov,
      promedio_profundidad: Util.formatear_decimal(promedio)
    }
  end

  # --- RECURSIVIDAD EXPLÍCITA DE COLA (TAIL RECURSION) ---

  defp procesar_recursivo([], conteo, max_mov, suma_prof) do
    {conteo, max_mov, suma_prof}
  end

  defp procesar_recursivo([m | resto], conteo, max_mov, suma_prof) do
    nuevo_conteo = conteo + 1
    nueva_suma = suma_prof + m.profundidad

    nuevo_max =
      cond do
        max_mov == nil -> m
        m.magnitud > max_mov.magnitud -> m
        true -> max_mov
      end

    procesar_recursivo(resto, nuevo_conteo, nuevo_max, nueva_suma)
  end
end
