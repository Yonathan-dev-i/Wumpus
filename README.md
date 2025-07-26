# 🏹 Mundo de Wumpus con Lógica de Primer Orden Avanzada

![Prolog](https://img.shields.io/badge/Prolog-Expert%20System-red) 
![AI](https://img.shields.io/badge/Artificial%20Intelligence-Logical%20Reasoning-blue)

Implementación mejorada del clásico "Wumpus World" utilizando razonamiento lógico sofisticado en Prolog. El agente inteligente deduce la ubicación de peligros (Wumpus y hoyos) mediante percepción e inferencia lógica.

## 🌟 Características Principales

- **Motor de Inferencia Avanzado**: Razonamiento basado en percepción (hedor, brisa, resplandor)
- **Sistema de Conocimiento Dinámico**: Base de hechos actualizada en tiempo real
- **Estrategias de Exploración**:
  - Búsqueda sistemática por filas
  - Retroceso seguro cuando hay peligro
  - Planificación de ruta de escape
- **Visualización Completa**: Mapa del mundo y conocimiento del agente
- **Sistema de Puntuación**: Recompensas/penalizaciones por acciones

## 🛠️ Requisitos

- [SWI-Prolog](https://www.swi-prolog.org) (versión 8.2.0 o superior)
- Terminal compatible con caracteres UTF-8

## 🚀 Cómo Ejecutar

1. Clona el repositorio:
- git clone https://github.com/Yonathan-dev-i/Wumpus.git
- cd Wumpus

## Inicia el juego en SWI-Prolog:
- ?- [wumpus_wer].
- ?- iniciar.

## 🎮 Comandos Disponibles

```prolog
% Comandos principales:
iniciar.                     % Comienza nueva partida
paso.                        % Ejecuta un turno de exploración
mostrar_mundo_completo.      % Muestra estado actual del mundo
mostrar_mapa_conocimiento.   % Visualiza lo que el agente ha deducido

% Comandos avanzados:
analizar_situacion_critica.  % Evalúa peligros inminentes
explorar_sistematicamente.   % Modo exploración automática
verificar_consistencia.      % Chequea coherencia del conocimiento
mostrar_estadisticas.        % Muestra métricas del juego

