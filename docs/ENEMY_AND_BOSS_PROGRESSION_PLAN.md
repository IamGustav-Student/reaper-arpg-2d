# Plan de Evolución de Enemigos y Bosses de Nivel

*(2026-08-11 — companion de `REAPER_DIRECTION_ANALYSIS.md`. Define Hitos 10 y 11+ del roadmap del GDD con números concretos.)*

---

## 1. El problema a resolver

Hoy el mundo es infinito (`ChunkManager`) pero **plano en dificultad**: un Mole/Treant a 10 chunks de la ruina es idéntico a uno pegado al spawn. No hay sensación de progresión al alejarse, y no hay ningún objetivo de "esto es difícil, prepárate" — el World Boss sigue siendo un párrafo del GDD (Sección 6.2), no algo con números.

Esto se resuelve con dos piezas separadas pero conectadas: **una curva de dificultad por distancia** (evolución de enemigos comunes) y **encuentros de Boss determinísticos** insertados en esa misma grilla de chunks.

---

## 2. Evolución de Enemigos: Tiers de Peligro por Distancia

`ChunkManager` ya calcula `coord: Vector2i` para cada chunk. Se agrega una función de **tier de peligro** basada en la distancia Chebyshev al origen (la ruina):

```gdscript
# en chunk_manager.gd
func _danger_tier(coord: Vector2i) -> int:
    var distance := max(absi(coord.x), absi(coord.y))
    if distance <= 1: return 0
    elif distance <= 3: return 1
    elif distance <= 6: return 2
    elif distance <= 10: return 3
    else: return 4
```

| Tier | Distancia (chunks) | Multiplicador de stats | Probabilidad de variante Élite | Enemigos disponibles |
|---|---|---|---|---|
| 0 | 1 (anillo del spawn) | x1.0 | 0% | Mole solamente |
| 1 | 2-3 | x1.0 | 0% | Mole + Treant (estado actual) |
| 2 | 4-6 | x1.5 | 15% | Mole + Treant |
| 3 | 7-10 | x2.2 | 30% | Mole + Treant |
| 4 | 11+ | x3.0 | 45% | Mole + Treant + **Boss chunks habilitados** |

### Variante Élite (sin arte nuevo)
No hay presupuesto de arte para nuevos sprites todavía, así que una "Élite" es la **misma textura con modulate tintado** (rojo/púrpura oscuro) + escala 1.3x adicional + stats x2 sobre el tier base + nombre con prefijo ("Mole Corrupto", "Treant Ancestral" — este último nombre se reserva para el Boss, ver Sección 3). Se implementa en `Enemy` con un flag `is_elite: bool`, seteado por `ChunkManager` al instanciar, no en el `.tscn` de cada enemigo.

```gdscript
# enemy.gd — agregar
@export var is_elite: bool = false

func _apply_elite_modifiers() -> void:
    if not is_elite:
        return
    health_system.max_health *= 2.0
    health_system.current_health = health_system.max_health
    scale *= 1.3
    modulate = Color(0.6, 0.1, 0.5)  # tinte púrpura oscuro
```

`ChunkManager._generate_forest_chunk()` ya elige el tipo de enemigo con `rng`; se agrega un segundo `rng.randf() < elite_chance_for_tier` para decidir `is_elite`, y se multiplican `move_speed`/`attack_cooldown`(más rápido)/daño del `AttackData` asignado según el multiplicador de tier — esto último requiere que el daño del enemigo deje de depender solo del `AttackData` fijo y consulte el tier (una línea: `attack_data.base_damage_multiplier * tier_multiplier`, ya que `Hurtbox.receive_hit` hace el cálculo final).

---

## 3. Boss de Nivel: "Treant Ancestral" (primer World Boss)

### Dónde aparece
No es aleatorio puro — es **determinístico por semilla**, igual que el resto de `ChunkManager`, para que sea reproducible: un chunk con `distance >= 5` es un **Boss Chunk** si `hash(coord) % 7 == 0`. Un Boss Chunk reemplaza el spawn normal de enemigos por **un solo Boss**, sin Mole/Treant regulares alrededor (para que el encuentro se sienta como un evento, no como "un Treant más entre otros").

### Stats (reusa el sprite de Treant existente, solo escala/números)
| Parámetro | Treant regular | Treant Ancestral (Boss) |
|---|---|---|
| Escala visual | 3x | **6x** |
| HP | 120 | **900** |
| Daño de golpe | via `treant_slam.tres` (mult 2.0) | mult **4.0** |
| Radio de ataque | 50 | **90** (barrido, no solo golpe puntual) |

### Las 3 fases (GDD Sección 6.2, ahora con implementación concreta)
1. **Fase 1 (100%-50% HP):** solo el ataque cuerpo a cuerpo ya existente (`Enemy._start_attack`, heredado sin cambios).
2. **Transición (al cruzar 50%):** el boss queda invulnerable 1.5s, tinte de `sprite_flash.gdshader` a blanco sostenido (no solo 1 frame, `flash_amount` se mantiene en 1.0 durante la transición) — reusa el shader ya construido, no uno nuevo.
3. **Fase 2 (50%-0%):** se suma un **ataque de área telegrafiado**: un círculo rojo transparente aparece 1.5s antes de un `Hitbox` de radio grande que se activa centrado en la posición del jugador *al momento en que empezó el telegraph* (no lo persigue — así el jugador puede leer y moverse, coherente con GDD 8.1 "Telegrafiado Rojo").

### Pieza técnica nueva: `TelegraphArea` (lo único que no reusa algo existente)
```gdscript
# scripts/combat/telegraph_area.gd
extends Node2D
class_name TelegraphArea

signal telegraph_finished

@export var warning_duration: float = 1.5
@export var radius: float = 90.0

func _ready() -> void:
    var timer := get_tree().create_timer(warning_duration)
    await timer.timeout
    telegraph_finished.emit()
    queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, Color(1.0, 0.15, 0.15, 0.35))
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, 0.8), 3.0)
```
El boss, al entrar en Fase 2, instancia un `TelegraphArea` en la posición del jugador, espera su señal `telegraph_finished`, y ahí activa un `Hitbox` grande en ese punto durante 0.2s. Nada de esto requiere un sistema de combate nuevo — es el mismo `Hitbox`/`AttackData` con un delay visual delante.

### Recompensa
Al morir: suelta **un Orbe de Alma único que vale 200 de Esencia** (`SoulOrb.essence_amount = 200`, en vez de instanciar varios orbes chicos) — de un solo golpe cubre gran parte de lo necesario para desbloquear runas en el Altar de Almas (Hito 8), dándole al primer Boss un propósito claro dentro del loop de progresión.

---

## 4. Roadmap actualizado (extiende, no repite, la Sección 9 del GDD)

| Hito | Contenido |
|---|---|
| **10** | Tiers de peligro por distancia + variante Élite (tintado, sin arte nuevo) en `ChunkManager`/`Enemy` |
| **11** | `TelegraphArea` + Boss Chunks determinísticos + "Treant Ancestral" (3 fases) |
| **12** | Segundo tipo de enemigo con ataque a distancia (variedad de amenaza — ya estaba planeado como Hito 10 antes de este documento, se corre un número) |

*(Nota: esto renumera lo que el análisis anterior llamaba "Hito 10: enemigo a distancia" y "Hito 11+: World Boss" — acá el Boss se concretó primero porque ya tiene todos los números definidos y no depende de conseguir/craftear un nuevo tipo de ataque a distancia.)*

---

## 5. Resumen ejecutivo

1. **La dificultad escala con la distancia al spawn** (5 tiers, multiplicador de stats + probabilidad de Élite), sin necesitar enemigos nuevos.
2. **Élite = mismo sprite, tintado + stats x2** — cero costo de arte.
3. **El primer Boss reusa el Treant** a 6x escala con 900 HP y 3 fases, usando el Hit Flash shader y el Hitbox/AttackData que ya existen — la única pieza técnica nueva es `TelegraphArea` (un círculo rojo con un timer).
4. **Los Boss Chunks son determinísticos** (mismo patrón de semilla que ya usa `ChunkManager`), no aleatorios puros — reproducibles y ubicables.
5. Recompensa del Boss conectada al Altar de Almas (Hito 8): un orbe grande, no un evento aislado sin consecuencia.
