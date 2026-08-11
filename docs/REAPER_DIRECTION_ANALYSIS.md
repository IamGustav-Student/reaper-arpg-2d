# Análisis de Rumbo — Las Crónicas de Reaper
## Estado actual, tensiones de diseño y dirección recomendada

*(2026-08-11, tras Hito 6 — Skill Tree UI. Companion de `ECHOES_OF_MYSTRALIA_ANALYSIS.md`.)*

---

## 1. Qué hay construido de verdad hoy (no lo que dice el GDD, lo que corre)

- **1 clase, 1 personaje, 1 arma fija.** El Player ataca con un único `AttackData` hardcodeado (`basic_sword.tres`). No existe ninguna noción de "clase" en el código — `StatSystem` es genérico (STR/AGI/INT/VIG/RUN), no hay Caballero/Mago/Cazador en ningún lado más que en el texto del GDD.
- **1 de 12 ramas de skill tree implementada.** Rama A del Cosechador (Sombras), con `available_points` fijo en 5 porque no hay XP ni subida de nivel conectada a nada.
- **Combate real pero mínimo.** Hitbox/Hurtbox funcionan, IA de perseguir+atacar funciona, Soul Harvest funciona (orbe vuela, se acredita). Pero solo hay 2 tipos de enemigo (Mole, Treant) y ninguno tiene ataques diferenciados más allá de "un golpe con más o menos daño".
- **Mundo infinito por chunks**, pero sin persistencia — matar algo no significa nada la próxima vez que pasás por ahí.
- **0% del sistema de loot/items**, **0% de World Bosses**, **0% de Fisuras Rúnicas**, **0% de Forja/Transmutación**. Estos siguen siendo párrafos de GDD, no código.

**Conclusión de esta sección:** el juego hoy es, en la práctica, *"un Cosechador con una espada y un árbol de habilidades a medio construir, en un bosque infinito sin memoria."* Eso está bien — es exactamente lo que un vertical slice debería ser. El problema no es lo poco que hay; es que el GDD sigue describiendo un juego 20x más grande sin que el roadmap diga explícitamente qué de eso es real y qué es aspiracional.

---

## 2. La tensión de diseño que el Soul-Crafting introdujo (y que hay que resolver, no ignorar)

La Sección 3.4 nueva (Soul-Crafting, inspirada en *Echoes of Mystralia*) y la Sección 5 vieja (Skill Tree con nodos activos fijos) **compiten por el mismo espacio de diseño**: ambas son "cómo el jugador consigue una habilidad activa nueva".

Tal como está escrito hoy, un jugador tendría:
- *Danza de las Hojas Sombrías* (activa, del Skill Tree, Tier 1) — un ataque giratorio fijo.
- Y **además** un sistema de Soul-Crafting donde combina runas de Forma+Modificador+Trigger para craftear... ¿otro ataque activo, separado?

Eso son dos fuentes de "botón de habilidad activa" sin relación entre sí. O el jugador termina con demasiados botones sin sentido narrativo, o uno de los dos sistemas queda de adorno. **Esto hay que decidirlo ahora, no dejarlo ambiguo para cuando ya haya código de los dos.**

### Resolución propuesta
**El Skill Tree deja de otorgar habilidades activas fijas. Otorga *slots* y *poder pasivo*. El Soul-Crafting es lo que llena esos slots.**

Concretamente, para Rama A (Sombras), reinterpretando lo que ya existe:
- **Tier 1** ya no es "Danza de las Hojas Sombrías" como habilidad fija — es el **desbloqueo del primer Slot de Runa Activa**. El contenido real (qué hace ese ataque) lo define la runa de Forma que el jugador craftee ahí.
- **Tier 2 y 4** (pasivos: Cuchillas Voraces, Seducción de la Oscuridad) **se quedan igual** — son crecimiento de poder puro, no compiten con nada.
- **Tier 3** (Paso Espectral) — mismo tratamiento que Tier 1: desbloquea el **Slot de Runa de Movilidad**.
- **Tier 5** (Keystone: Frenesí de Almas Desatadas) **se queda como está** — un Keystone fijo y espectacular es exactamente lo que un Hito Maestro debería ser; no todo tiene que ser modular.

Con esto, los dos sistemas dejan de competir: **el Skill Tree responde "cuánto poder tenés y cuántos slots activos tenés disponibles"; el Soul-Crafting responde "qué hace cada slot."** Es además más fiel al espíritu de *Echoes of Mystralia* que citó el análisis: ahí tampoco reemplazás el árbol de talentos, el spellcrafting vive *adentro* de los slots que el árbol te da.

---

## 3. La segunda tensión: de dónde salen las runas

El GDD nuevo no dice de dónde saca el jugador las runas para craftear. Si esto queda suelto, va a terminar siendo "otra moneda más" sin conexión con el resto del juego. Pero **ya existe una mecánica insignia hecha para esto**: la Cosecha de Almas.

### Resolución propuesta
Las runas se craftean/desbloquean gastando **Esencia de Alma** (la misma que ya llena `SoulHarvestManager.soul_meter` al matar enemigos) en un **Altar de Almas** — no una moneda nueva, no un sistema de drops paralelo. Esto:
- Refuerza el core loop ya construido (matar → cosechar almas → ahora *también* craftear poder) en vez de sumarle un loop nuevo sin relación.
- Le da un uso permanente al alma cosechada más allá de la Furia Rúnica temporal — hoy el medidor de almas solo sirve para llenarse y activar furia; con esto, el jugador tiene una razón para acumular almas incluso fuera de combate.

---

## 4. Tercera tensión: alcance de clases

El GDD (incluso recortado) sigue listando 4 clases. El código no tiene ninguna noción de clase. Mantener esa ambigüedad activa el riesgo de que en algún momento se "empiece" el Mago o el Cazador sin haber terminado el Cosechador, repitiendo el patrón de dispersión que ya se corrigió una vez con la decisión de "vertical slice primero".

### Resolución propuesta
**Cosechador es la única clase en desarrollo activo.** Caballero/Mago/Cazador quedan como **notas de diseño a futuro** (vale la pena dejarlas escritas, tienen buenas ideas), pero no son un item de roadmap hasta que el Cosechador esté completo end-to-end: sus 3 ramas, su Soul-Crafting, sus enemigos y al menos un boss. El nombre del juego es *Las Crónicas de **Reaper***; tiene sentido que el Cosechador sea el producto mínimo completo antes de pensar en multiclase.

---

## 5. Riesgo de alcance del Soul-Crafting específicamente

Un sistema de crafteo verdaderamente modular (N formas × M modificadores × K triggers) escala combinatoriamente. Con arte placeholder y sin artista, cada combinación *no* necesita una animación/VFX única para sentirse bien — puede diferenciarse por números (daño, radio, duración, knockback) reusando el mismo Hitbox/AttackData que ya existe, más el shader de Hit Flash y partículas genéricas ya construidos.

### Resolución propuesta para el prototipo (Hito 7)
Empezar deliberadamente chico: **3 Runas de Forma × 2 Runas de Modificador × 2 Runas de Trigger** (12 combinaciones posibles, no infinitas) es suficiente para probar que el sistema se siente bien antes de invertir en más contenido. Arquitectura concreta, reusando lo que ya existe:

```gdscript
# scripts/data/rune_data.gd (ya está en el GDD, esto es cómo se conecta al código real)
extends Resource
class_name RuneData

enum RuneCategory { SHAPE, MODIFIER, TRIGGER }

@export var rune_name: String = ""
@export var category: RuneCategory = RuneCategory.SHAPE
@export var damage_multiplier_delta: float = 0.0   # se suma al AttackData base
@export var knockback_delta: float = 0.0
@export var hitbox_radius_multiplier: float = 1.0   # una Forma "Nova" agranda el hitbox
@export var applies_dot: bool = false               # una Runa de Ceniza aplica daño por tiempo
@export var lifesteal_percent: float = 0.0          # una Runa de Sed de Sangre cura al golpear

# RuneSpellBuilder no crea un sistema nuevo de combate: combina 1-3 RuneData
# en un AttackData temporal (Resource duplicado en runtime), reusando el
# Hitbox/Hurtbox que YA existe. Cero sistemas de combate paralelos.
```

Esto significa que Hito 7 es "extender AttackData con un compositor de runas", no "construir un motor de hechizos nuevo". Mucho más chico de lo que suena la Sección 3.4 tal como está escrita.

---

## 6. Roadmap recomendado (reemplaza el propuesto en el GDD)

| Hito | Contenido | Por qué en este orden |
|---|---|---|
| **7** | `RuneData` (Resource) + 3 Formas + 2 Modificadores + 2 Triggers como `.tres` reales + `RuneSpellBuilder` que compone un `AttackData` temporal | Extiende arquitectura existente, sin UI todavía — se puede probar por código/debug scene antes de invertir en interfaz |
| **8** | Altar de Almas (UI) — gastar Esencia de Alma para desbloquear runas, equipar 1 runa por slot activo (Tier 1 y Tier 3 del Skill Tree pasan a ser "slots", no habilidades fijas) | Conecta Soul-Crafting con Soul Harvest, resuelve la Sección 2 de este documento |
| **9** | Persistencia de chunks/enemigos (el "Hito 7" original, renumerado) | Ya no compite en prioridad con Soul-Crafting, pero sigue siendo necesario para que el mundo infinito se sienta real |
| **10** | Segundo tipo de enemigo con ataque a distancia (variedad de amenaza, no solo "cuerpo a cuerpo con más HP") | El combate necesita variedad de amenazas antes de necesitar más clases |
| **11+** | Boss de mundo (telegrafiado + fases, ya especificado en GDD Sección 6.2) usando Treant como base reescalada | Primer objetivo de "final" del vertical slice — cerrar el loop completo: explorar → craftear poder → boss |

Las otras 3 clases y las ramas B/C restantes del Cosechador quedan fuera de este roadmap a propósito — son contenido, se agregan cuando el sistema (no el contenido) esté probado.

---

## 7. Resumen ejecutivo

1. **Skill Tree = poder pasivo + slots. Soul-Crafting = contenido de esos slots.** No son dos sistemas paralelos, es una jerarquía.
2. **Las runas se compran con Esencia de Alma**, no con una moneda nueva — reutiliza lo ya construido.
3. **Una sola clase (Cosechador) hasta completarla end-to-end.** Las otras 3 son notas, no roadmap.
4. **Soul-Crafting v1 es chico a propósito** (12 combinaciones, no "infinitas") y se implementa extendiendo `AttackData`, no como sistema nuevo.
5. El roadmap técnico pasa a ser: **Runas de código → Altar de UI → Persistencia de chunks → Variedad de enemigos → Boss.**
