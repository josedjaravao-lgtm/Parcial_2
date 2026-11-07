base_dir = Path.expand("../../Punto-1", __DIR__)
Code.require_file(Path.join(base_dir, "ciudad.exs"))
Code.require_file(Path.join(base_dir, "movimiento.exs"))
Code.require_file(Path.join(base_dir, "util.exs"))
Code.require_file(Path.join(base_dir, "parser.exs"))
Code.require_file(Path.join(base_dir, "calculador.exs"))
Code.require_file(Path.join(base_dir, "coordinador.exs"))
Code.require_file(Path.join(base_dir, "reporte.exs"))

defmodule ServidorSismos do
  def iniciar do
    Process.register(self(), :servicio_sismos)
    Util.mostrar_mensaje("[SERVIDOR] Proceso :servicio_sismos registrado en el nodo: #{Node.self()}...\n")

    bucle_servidor()
  end

  defp bucle_servidor do
    receive do
      {destino_respuesta, {:reporte_ciudad, id_ciudad}} ->
        respuesta = procesar_reporte_ciudad(id_ciudad)
        send(destino_respuesta, {:respuesta, respuesta})
        bucle_servidor()

      {destino_respuesta, :reporte_general} ->
        respuesta = procesar_reporte_general()
        send(destino_respuesta, {:respuesta, respuesta})
        bucle_servidor()

      {destino_respuesta, :fin} ->
        send(destino_respuesta, {:respuesta, :fin})
        Util.mostrar_mensaje("[SERVIDOR] Cliente finalizó sesión. Volviendo a esperar solicitudes...\n")
        bucle_servidor()
    end
  end

  defp leer_datos_actuales do
    ruta_ciudades = Path.join([__DIR__, "resources", "ciudades.txt"])
    ruta_movs = Path.join([__DIR__, "resources", "movimientos.txt"])
    Coordinador.leer_archivos_concurrentes(ruta_ciudades, ruta_movs)
  end

  defp procesar_reporte_ciudad(id_ciudad) do
    case leer_datos_actuales() do
      {:ok, {:ok, {ciudades, _rech_c}}, {:ok, {movimientos_raw, _rech_m_sintaxis}}} ->
        {movimientos, _} = Calculador.filtrar_movimientos_por_ciudades(movimientos_raw, ciudades)
        ciudad_encontrada = Enum.find(ciudades, fn c -> c.id_ciudad == id_ciudad end)

        if ciudad_encontrada do
          reportes = Calculador.generar_estadisticas_globales([ciudad_encontrada], movimientos)
          Main.construir_texto_reporte(reportes, 0, 0)
        else
          "La ciudad no está registrada"
        end

      {:ok, {:error, razon}, _} ->
        "Error al leer el archivo de ciudades: #{inspect(razon)}"

      {:ok, _, {:error, razon}} ->
        "Error al leer el archivo de movimientos: #{inspect(razon)}"

      {:error, :timeout} ->
        "Error: Timeout al leer los archivos de entrada"
    end
  end

  defp procesar_reporte_general do
    case leer_datos_actuales() do
      {:ok, {:ok, {ciudades, rech_c}}, {:ok, {movimientos_raw, rech_m_sintaxis}}} ->
        {movimientos, rech_m_ciudad} = Calculador.filtrar_movimientos_por_ciudades(movimientos_raw, ciudades)
        rech_m_total = rech_m_sintaxis + rech_m_ciudad
        reportes = Calculador.generar_estadisticas_globales(ciudades, movimientos)
        Main.construir_texto_reporte(reportes, rech_c, rech_m_total)

      {:ok, {:error, razon}, _} ->
        "Error al leer el archivo de ciudades: #{inspect(razon)}"

      {:ok, _, {:error, razon}} ->
        "Error al leer el archivo de movimientos: #{inspect(razon)}"

      {:error, :timeout} ->
        "Error: Timeout al leer los archivos de entrada"
    end
  end
end

ServidorSismos.iniciar()
