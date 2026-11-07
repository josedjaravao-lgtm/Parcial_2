base_dir = Path.expand("../../Punto-1", __DIR__)
Code.require_file(Path.join(base_dir, "util.exs"))

defmodule ClienteSismos do
  def iniciar(id_con_mov, id_sin_mov, id_inexistente) do
    Process.register(self(), :servicio_respuesta)

    # Detectar el hostname del equipo dinámicamente
    nodo_actual = to_string(Node.self())
    [_name, host] = String.split(nodo_actual, "@")
    nombre_nodo_servidor = String.to_atom("servidor@" <> host)

    Util.mostrar_mensaje("[CLIENTE] Intentando conectar con el nodo servidor: #{nombre_nodo_servidor}...")

    if Node.connect(nombre_nodo_servidor) do
      Util.mostrar_mensaje("[CLIENTE] Conexión establecida con éxito.\n")

      destino_respuesta = {:servicio_respuesta, Node.self()}
      servidor = {:servicio_sismos, nombre_nodo_servidor}

      # 1. Ciudad con movimientos registrados
      send(servidor, {destino_respuesta, {:reporte_ciudad, id_con_mov}})

      # 2. Ciudad sin movimientos registrados
      send(servidor, {destino_respuesta, {:reporte_ciudad, id_sin_mov}})

      # 3. Ciudad inexistente
      send(servidor, {destino_respuesta, {:reporte_ciudad, id_inexistente}})

      # 4. Reporte general
      send(servidor, {destino_respuesta, :reporte_general})

      # 5. Mensaje :fin
      send(servidor, {destino_respuesta, :fin})

      escuchar_respuestas()
    else
      Util.mostrar_mensaje("[ERROR CLIENTE] No se pudo conectar al nodo servidor: #{nombre_nodo_servidor}")
    end
  end

  defp escuchar_respuestas do
    receive do
      {:respuesta, :fin} ->
        Util.mostrar_mensaje("\n[CLIENTE] Confirmación de fin recibida del servidor. Proceso finalizado.")

      {:respuesta, contenido} ->
        Util.mostrar_mensaje("\n------------------- RESPUESTA DEL SERVIDOR -------------------")
        Util.mostrar_mensaje(contenido)
        Util.mostrar_mensaje("--------------------------------------------------------------")
        escuchar_respuestas()
    after
      10000 ->
        Util.mostrar_mensaje("[CLIENTE] Tiempo de espera agotado sin recibir respuesta.")
    end
  end
end

ClienteSismos.iniciar("C01", "C03", "C999")
