# 🏹 Mundo de Wumpus con Lógica de Primer Orden Avanzada

![Prolog](https://img.shields.io/badge/Prolog-Expert%20System-red) 
![AI](https://img.shields.io/badge/Artificial%20Intelligence-Logical%20Reasoning-blue)

Implementación mejorada del clásico "Wumpus World" utilizando razonamiento lógico sofisticado en Prolog. El agente inteligente deduce la ubicación de peligros (Wumpus y hoyos) mediante percepción e inferencia lógica.

# Razonamiento Lógico Avanzado en el Mundo del Wumpus con Prolog

Este repositorio implementa el juego del **Mundo del Wumpus** utilizando **lógica de primer orden** en Prolog. El agente emplea un razonamiento sofisticado para explorar un tablero de 4x4, evitar peligros (hoyos y Wumpus), recolectar oro y regresar a la posición inicial de manera segura. La implementación incluye un motor de inferencia avanzado, manejo de percepciones (hedor, brisa, resplandor, grito) y estrategias de exploración sistemática.

## Descripción del Proyecto

El **Mundo del Wumpus** es un problema clásico de inteligencia artificial que pone a prueba la capacidad de un agente para razonar en un entorno incierto. En este proyecto, el agente utiliza lógica de primer orden para:
- Inferir la ubicación de peligros (Wumpus y hoyos) basándose en percepciones.
- Determinar casillas seguras para explorar.
- Planificar movimientos óptimos, incluyendo retroceso y disparo de flecha.
- Visualizar el estado del mundo y el conocimiento del agente.

### Características Principales
- **Razonamiento lógico**: Deduce casillas seguras y peligrosas mediante reglas de lógica de primer orden.
- **Exploración inteligente**: Prioriza casillas seguras y usa retroceso cuando no hay opciones seguras.
- **Gestión de percepciones**: Procesa hedor (Wumpus cercano), brisa (hoyo cercano), resplandor (oro) y grito (Wumpus eliminado).
- **Sistema de puntuación**: Penaliza movimientos (-1), disparos (-10) y caídas/devoraciones (-1000), y premia la victoria (+1000).
- **Visualización avanzada**: Muestra el tablero, el conocimiento del agente y estadísticas del juego.

## Estructura del Repositorio

- `Wumpus.pl`: Archivo principal en Prolog que contiene la implementación completa del juego, incluyendo inicialización, percepción, inferencia, toma de decisiones y visualización.
- `README.md`: Este archivo, que describe el proyecto y cómo usarlo.

## Requisitos

- **SWI-Prolog**: Versión 8.0 o superior (disponible en [swi-prolog.org](https://www.swi-prolog.org/)).
- No se requieren dependencias adicionales, ya que el código es autónomo.

## Cómo Ejecutar

1. **Instalar SWI-Prolog**:
   - Descarga e instala SWI-Prolog desde [swi-prolog.org](https://www.swi-prolog.org/download/stable).
   - Asegúrate de que el comando `swipl` esté disponible en tu terminal.

2. **Clonar o descargar el repositorio**:
   ```bash
   git clone https://github.com/Yonathan-dev-i/Wumpus.git
   cd Wumpus
   ```

3. **Cargar el programa en SWI-Prolog**:
   - Abre SWI-Prolog en tu terminal ejecutando:
     ```bash
     swipl
     ```
   - Carga el archivo `Wumpus.pl`:
     ```prolog
     ?- [Wumpus].
     ```

4. **Iniciar el juego**:
   - Para comenzar un juego completo con exploración automática:
     ```prolog
     ?- iniciar.
     ```
   - Para ejecutar el juego paso a paso:
     ```prolog
     ?- paso.
     ```
   - Otros comandos útiles:
     ```prolog
     ?- ayuda.                 % Muestra todos los comandos disponibles
     ?- mostrar_mundo_completo. % Visualiza el estado del mundo
     ?- mostrar_mapa_conocimiento. % Muestra el conocimiento del agente
     ?- mostrar_estadisticas.   % Muestra estadísticas del juego
     ?- simular_ejemplo_libro. % Ejecuta un escenario predefinido
     ```

5. **Jugar**:
   - El agente explora automáticamente el tablero, procesando percepciones y tomando decisiones.
   - Observa la salida en consola para ver el tablero, el conocimiento del agente y las decisiones tomadas.
   - El juego termina cuando el agente recoge el oro y regresa a (1,1) (victoria), cae en un hoyo, es devorado por el Wumpus, o se queda sin opciones.

## Detalles de la Implementación

- **Tablero**: Cuadrícula de 4x4 con un Wumpus, un oro y tres hoyos generados aleatoriamente (excluyendo la posición inicial (1,1)).
- **Percepciones**:
  - Hedor: Indica Wumpus en casilla adyacente.
  - Brisa: Indica hoyo en casilla adyacente.
  - Resplandor: Indica oro en la casilla actual.
  - Grito: Indica que el Wumpus fue eliminado tras disparar la flecha.
- **Acciones del agente**:
  - Avanzar, girar (izquierda/derecha), disparar flecha, agarrar oro.
  - Retroceso estratégico si no hay casillas seguras.
  - Exploración sistemática por filas para cubrir el tablero.
- **Inferencia lógica**:
  - Deduce casillas seguras eliminando posibles Wumpus/hoyos según percepciones.
  - Marca casillas como `seguro/2`, `posible_wumpus/2`, o `posible_hoyo/2`.
  - Detecta inconsistencias en la base de conocimiento.
- **Puntuación**:
  - -1 por movimiento o giro.
  - -10 por disparar la flecha.
  - -1000 por caer en un hoyo o ser devorado.
  - +1000 por regresar a (1,1) con el oro.

## Ejemplo de Uso

```prolog
?- iniciar.
=== MUNDO DE WUMPUS - VERSIÓN AVANZADA ===
Con Lógica de Primer Orden y Razonamiento Sofisticado
Puntuación: 0
=== ESTADO COMPLETO DEL MUNDO ===
Tablero (W=Wumpus, G=Oro, H=Hoyo, A=Agente):
4 . . . H
3 . G H .
2 . . . .
1 A . W .
  1 2 3 4
...
Iniciando exploración inteligente...
Percepción en (1,1): [hedor,nada,nada,nada]
Analizando percepción en (1,1): [hedor,nada,nada,nada]
 -> Hedor detectado: Wumpus en casilla adyacente
...
```

## Notas

- El agente prioriza casillas seguras y usa un enfoque cauteloso si no hay opciones seguras, retrocediendo por rutas conocidas.
- La simulación del ejemplo del libro (`simular_ejemplo_libro`) recrea un escenario clásico con posiciones fijas de Wumpus, oro y hoyos.
- La visualización del tablero y del conocimiento del agente ayuda a depurar y entender las decisiones del agente.
- El código está optimizado para ser legible y modular, con comentarios en español para facilitar la comprensión.

## Autor

- **Yonathan Muriel** ([Yonathan-dev-i](https://github.com/Yonathan-dev-i))
- Correo: yonathan1muriel@gmail.com

