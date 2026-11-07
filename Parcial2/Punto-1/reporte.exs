Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("util.exs", __DIR__)
Code.require_file("parser.exs", __DIR__)
Code.require_file("calculador.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)

defmodule Main do
  def ejecutar do
    ruta_ciudades = Path.join([__DIR__, "resources", "ciudades.txt"])
    ruta_movs = Path.join([__DIR__, "resources", "movimientos.txt"])
    ruta_reporte = Path.join([__DIR__, "resources", "reporte_sismos.txt"])

    case Coordinador.leer_archivos_concurrentes(ruta_ciudades, ruta_movs) do
      {:ok, {:ok, {ciudades, rech_c}}, {:ok, {movimientos_raw, rech_m_sintaxis}}} ->
        {movimientos, rech_m_ciudad} =
          Calculador.filtrar_movimientos_por_ciudades(movimientos_raw, ciudades)

        rech_m_total = rech_m_sintaxis + rech_m_ciudad
        reportes_ciudades = Calculador.generar_estadisticas_globales(ciudades, movimientos)
        texto_reporte = construir_texto_reporte(reportes_ciudades, rech_c, rech_m_total)

        Util.mostrar_mensaje(texto_reporte)

        case File.write(ruta_reporte, texto_reporte) do
          :ok ->
            Util.mostrar_mensaje("\n[OK] Reporte guardado con éxito en: #{ruta_reporte}")

          {:error, razon} ->
            Util.mostrar_mensaje("\n[ERROR] Falla al escribir el reporte: #{inspect(razon)}")
        end

      {:ok, {:error, razon}, _} ->
        Util.mostrar_mensaje("[ERROR] No se pudo leer el archivo de ciudades: #{inspect(razon)}")

      {:ok, _, {:error, razon}} ->
        Util.mostrar_mensaje("[ERROR] No se pudo leer el archivo de movimientos: #{inspect(razon)}")

      {:error, :timeout} ->
        Util.mostrar_mensaje("[ERROR] Tiempo de espera agotado al leer los archivos.")
    end
  end

  def construir_texto_reporte(reportes_ciudades, rech_c, rech_m) do
    encabezado = """
    ================================================================================
    REPORTES DE MOVIMIENTOS SÍSMICOS POR CIUDAD
    ================================================================================
    """

    cuerpo =
      Enum.map_join(reportes_ciudades, "\n--------------------------------------------------------------------------------\n", fn r ->
        ciudad = r.ciudad
        movs = r.movimientos

        detalle_movs =
          if movs == [] do
            "  * Sin movimientos registrados"
          else
            Enum.map_join(movs, "\n", fn m ->
              "  * Código: #{m.codigo} | Inicio: #{m.hora_inicio} | Fin: #{m.hora_final} | Mag: #{m.magnitud} | Prof: #{m.profundidad} km"
            end)
          end

        info_max =
          if r.max_movimiento do
            "#{r.max_movimiento.codigo} (#{r.max_movimiento.magnitud})"
          else
            "No aplica"
          end

        """
        Ciudad: #{ciudad.nombre} (ID: #{ciudad.id_ciudad})
        Habitantes: #{ciudad.numero_habitantes}
        Detalle de Movimientos:
        #{detalle_movs}
        Total de Movimientos: #{r.total}
        Movimiento de Mayor Magnitud: #{info_max}
        Profundidad Promedio: #{r.promedio_profundidad} km
        """
      end)

    pie = """

    ================================================================================
    REGISTROS RECHAZADOS
    ================================================================================
    * Archivo Ciudades: #{rech_c} registro(s) rechazado(s)
    * Archivo Movimientos: #{rech_m} registro(s) rechazado(s)
    ================================================================================
    """

    encabezado <> cuerpo <> pie
  end
end

Main.ejecutar()
