Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("util.exs", __DIR__)

defmodule Parser do
  @doc """
  Parsea las líneas de ciudades.
  Retorna {lista_ciudades_validas, total_rechazados}
  """
  def procesar_ciudades(lineas) do
    {validos, rechazados} =
      Enum.reduce(lineas, {[], 0}, fn linea, {acc_validos, acc_rechazados} ->
        linea_limpia = String.trim(linea)

        if linea_limpia == "" do
          {acc_validos, acc_rechazados}
        else
          case parsear_ciudad(linea_limpia) do
            {:ok, ciudad} ->
              {[ciudad | acc_validos], acc_rechazados}

            :error ->
              {acc_validos, acc_rechazados + 1}
          end
        end
      end)

    {Enum.reverse(validos), rechazados}
  end

  defp parsear_ciudad(linea) do
    case String.split(linea, "@") do
      [id_ciudad, nombre, habitantes_str] ->
        id_limpio = String.trim(id_ciudad)
        nom_limpio = String.trim(nombre)

        with true <- Util.texto_valido?(id_limpio),
             true <- Util.texto_valido?(nom_limpio),
             {:ok, habs} <- parse_entero_positivo(habitantes_str) do
          {:ok, %Ciudad{id_ciudad: id_limpio, nombre: nom_limpio, numero_habitantes: habs}}
        else
          _ -> :error
        end

      _ ->
        :error
    end
  end

  @doc """
  Parsea las líneas de movimientos.
  Retorna {lista_movimientos_validos, total_rechazados}
  """
  def procesar_movimientos(lineas) do
    {validos, rechazados} =
      Enum.reduce(lineas, {[], 0}, fn linea, {acc_validos, acc_rechazados} ->
        linea_limpia = String.trim(linea)

        if linea_limpia == "" do
          {acc_validos, acc_rechazados}
        else
          case parsear_movimiento(linea_limpia) do
            {:ok, movimiento} ->
              {[movimiento | acc_validos], acc_rechazados}

            :error ->
              {acc_validos, acc_rechazados + 1}
          end
        end
      end)

    {Enum.reverse(validos), rechazados}
  end

  defp parsear_movimiento(linea) do
    case String.split(linea, "@") do
      [codigo, id_ciudad, hora_ini, hora_fin, mag_str, prof_str] ->
        cod_limpio = String.trim(codigo)
        id_limpio = String.trim(id_ciudad)

        with true <- Util.texto_valido?(cod_limpio),
             true <- Util.texto_valido?(id_limpio),
             true <- validar_hora(hora_ini),
             true <- validar_hora(hora_fin),
             {:ok, mag} <- parse_float(mag_str),
             {:ok, prof} <- parse_float(prof_str),
             true <- prof >= 0.0 do
          {:ok,
           %Movimiento{
             codigo: cod_limpio,
             id_ciudad: id_limpio,
             hora_inicio: String.trim(hora_ini),
             hora_final: String.trim(hora_fin),
             magnitud: mag,
             profundidad: prof
           }}
        else
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp parse_entero_positivo(str) do
    case Integer.parse(String.trim(str)) do
      {num, ""} when num > 0 -> {:ok, num}
      _ -> :error
    end
  end

  defp parse_float(str) do
    case Float.parse(String.trim(str)) do
      {num, ""} -> {:ok, num}
      _ -> :error
    end
  end

  defp validar_hora(str) do
    case Time.from_iso8601(String.trim(str)) do
      {:ok, _time} -> true
      _ -> false
    end
  end
end
