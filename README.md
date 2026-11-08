Estructura del Repositorio

README.md
Parcial2/
├── punto-1/
│   ├── main.exs
│   ├── coordinador.exs
│   ├── parser.exs
│   ├── calculador.exs
│   ├── structs.exs
│   └── resources/
│       ├── ciudades.txt
│       ├── movimientos.txt
│       └── reporte_sismos.txt
└── punto-2/
    ├── nodo-cliente/
    │   └── cliente.exs
    └── nodo-servidor/
        ├── servidor.exs
        └── resources/
            ├── ciudades.txt
            └── movimientos.txt


 Punto 1: Reporte Local Concurrente

Descripción

Procesa de forma concurrente los archivos ciudades.txt y movimientos.txt. El proceso coordinador lanza dos procesos trabajadores con spawn que leen los archivos y devuelven los resultados mediante send. Los datos se calculan mediante recursión de cola en un único recorrido.

Ejecución

cd punto-1
elixir main.exs


El resultado se imprimirá en consola y se guardará en punto-1/resources/reporte_sismos.txt.

Punto 2: Consulta entre Nodos Distribuidos

Identificadores de Prueba Usados

Ciudad con movimientos: C01 (Armenia)

Ciudad sin movimientos: C03 (Circasia)

Ciudad inexistente: C999

Instrucciones de Ejecución

1. Iniciar Nodo Servidor (Terminal 1)

cd punto-2/nodo-servidor
elixir --sname servidor --cookie clave123 .\servidor.exs


2. Iniciar Nodo Cliente (Terminal 2)

cd punto-2/nodo-cliente
elixir --sname cliente --cookie clave123 .\cliente.exs

3. Verificación de Atendimiento Continuo

Para comprobar que el servidor sigue activo tras recibir :fin, vuelve a ejecutar el cliente en la Terminal 2:
elixir --sname cliente --cookie clave123 .\cliente.exs


