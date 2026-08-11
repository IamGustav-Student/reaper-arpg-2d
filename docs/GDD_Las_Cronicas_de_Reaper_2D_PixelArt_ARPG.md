# Las Crónicas de Reaper: El Despertar de las Runas
## Documento Maestro de Diseño y Desarrollo (GDD ARPG 2D — Arte Pintado/Chibi)

---

## 1. Visión General y Estrategia de Pivotaje (3D MMORPG -> 2D ARPG de Arte Pintado)

### 1.1 Justificación del Cambio de Alcance
El concepto original de *Las Crónicas de Reaper* estaba concebido como un MMORPG 3D masivo. Sin embargo, para un equipo de desarrollo independiente o focalizado, los proyectos MMORPG 3D presentan barreras críticas de desarrollo: altísima complejidad de red, costos de producción de assets 3D, pruebas de servidores masivos y riesgos elevados de cancelación.

Al migrar hacia un **ARPG 2D Top-Down / Isometric con arte pintado de alto detalle**, el proyecto obtiene múltiples ventajas estratégicas:
* **Viabilidad de Producción:** Permite crear contenido denso, detallado y pulido de forma ágil mediante pipelines de arte 2D (frente al 3D), manteniendo un nivel de detalle pictórico superior al de un pixel art de grilla baja.
* **Foco en el "Game Juice" y Combate Fluido:** Los juegos de acción 2D permiten lograr una respuesta de control inmediata, animaciones hiper-reactivas (cancelación de cuadros, esquivas con invulnerabilidad) y una satisfacción táctil superior.
* **Estética Atemporal:** Un estilo pintado de alto detalle con proporciones chibi e iluminación dramática de shaders 2D (torchlight, brillo de armas) envejece con elegancia y tiene un atractivo visual fuerte dentro de la comunidad de jugadores en Steam e Itch.io.

### 1.2 Referentes de Diseño del Sector
* **Battle Chasers: Nightwar:** Referente principal de dirección de arte — personajes pintados de proporciones "chibi" (cabeza grande, cuerpo pequeño), iluminación dramática y detalle pictórico sobre una cámara 3/4 top-down. Es el referente visual más cercano a la imagen de concepto aprobada para Reaper.
* **Echoes of Mystralia (Borealys Games - 2026):** Referente principal de **creación libre y modular de habilidades (Spellcrafting / Soul-Crafting)**, ritmo de combate en perspectiva isométrica y sistema de fisuras/brechas procedurales para el endgame.
* **Eternium & Diablo Immortal (versión móvil):** Referentes en HUD de combate (orbes de Vida/Maná, barra de habilidades inferior) y en cómo un estilo pintado de alto detalle se integra con partículas y efectos de arma brillante.
* **Bastion:** Referente en atmósfera de mazmorra pintada, paletas cálidas de antorchas contra piedra oscura, y cámara fija 3/4 que enmarca el combate.
* **The Slormancer & Chronicon:** Referentes en profundidad de árboles de habilidades, personalización de build, recolección de loot y escalabilidad de números en endgame.
* **Children of Morta:** Referente en la animación frame-by-frame narrativa y el impacto de los efectos visuales en combates contra hordas (independiente del estilo de arte final).

> **Nota (2026-08-08):** el proyecto pivotó de Pixel Art de grilla baja a un estilo **pintado/chibi de mayor resolución** (ver imagen de referencia `WhatsApp Image 2026-08-08 at 16.45.48.jpeg`), manteniendo intactos el core loop, sistema de combate, stats, skill trees y loot del resto de este documento — el cambio es puramente de dirección de arte y su pipeline técnico asociado (Secciones 1.4 y 2).

> **Nota (2026-08-11 — alcance de clase, ver `REAPER_DIRECTION_ANALYSIS.md`):** de las 4 clases descritas en la Sección 5, **solo el Cosechador está en desarrollo activo**. Caballero Guardián, Mago Rúnico y Cazador de Sombras quedan como notas de diseño a futuro, no como items de roadmap, hasta que el Cosechador esté completo end-to-end (sus 3 ramas, su Soul-Crafting, y al menos un World Boss). El nombre del juego es *Las Crónicas de Reaper*; el Cosechador es el producto mínimo completo antes de pensar en multiclase.

### 1.3 Core Loop de Juego
```
               ┌──────────────────────────────────────────┐
               │    Exploración de Zonas y Fisuras 2D    │
               └────────────────────┬─────────────────────┘
                                    │
                                    ▼
               ┌──────────────────────────────────────────┐
               │  Combate Rápido & Cosecha de Almas (Soul)│
               └────────────────────┬─────────────────────┘
                                    │
                                    ▼
               ┌──────────────────────────────────────────┐
               │ Recolección de Loot Rúnico & Materiales  │
               └────────────────────┬─────────────────────┘
                                    │
                                    ▼
               ┌──────────────────────────────────────────┐
               │ Asignación de Stats & Árbol de Habilidades│
               └────────────────────┬─────────────────────┘
                                    │
                                    ▼
               ┌──────────────────────────────────────────┐
               │ Forja Rúnica & Desafíos Endgame (Bosses) │
               └──────────────────────────────────────────┘
```

### 1.4 Cámara, Perspectiva y Resolución Objetivo
* **Perspectiva:** Visión 3/4 Top-Down (Ángulo cenital inclinado a 45°). Permite apreciar la altura de los personajes, sus spritesheets frontales/posteriores y la profundidad del terreno sin la complejidad de una verdadera cámara isométrica de 60°.
* **Resolución Base de Diseño:** **1280 × 720 píxeles** (Aspect Ratio 16:9). A diferencia de un pipeline de Pixel Art clásico, no se fuerza una grilla de píxeles ni un escalado entero: los sprites pintados de alta resolución escalan de forma fraccional y suave a cualquier resolución de pantalla (1080p, 1440p, 4K) sin necesidad de múltiplos exactos.
* **Filtrado Suave:** Al no perseguir bordes de píxel nítidos, se usa filtrado `Linear` en texturas (en vez del `Nearest`/`Point` de un pipeline pixel art), preservando el detalle pictórico de los sprites al escalar.

---

## 2. Dirección Artística y Pipeline Técnico 2D (Pintado/Chibi de Alto Detalle)

### 2.1 Especificaciones de Arte y Sprites
* **Escala Mundo-Píxel:** 1 unidad de mundo en Godot = 1 píxel de textura al 100% de escala del `Sprite2D` (sin grilla de PPU fija; el escalado de cada sprite se ajusta visualmente en el editor según su tamaño de frame).
* **Tamaño de Tilesets:** Tiles de **128×128** píxeles para piso, muros y estructuras (proporcionales al tamaño de personaje, a diferencia de los 32×32 de un pipeline pixel art).
* **Tamaño de Spritesheets de Personajes:**
  * Personajes/Jugadores: Grilla de **128×128** píxeles por frame (proporciones chibi: cabeza grande, cuerpo pequeño, según la referencia visual aprobada).
  * Enemigos Normales: Grilla de **128×128** píxeles.
  * Bosses de Mundo: Grilla de **256×256** a **384×384** píxeles.
* **Detalle Pictórico:** Sombreado pintado a mano (luces/sombras suaves, sin dithering de pixel art), con contornos oscuros marcados para legibilidad a distancia — igual que el tratamiento de personajes y enemigos en la imagen de referencia.
* **Direccionalidad de Animación:**
  * Movimiento y Combate en **4 Direcciones principales** (Abajo, Arriba, Izquierda, Derecha). La dirección Izquierda/Derecha se maneja invirtiendo la escala X (`flipX = true`).
  * Conjunto mínimo de animaciones por personaje:
    1. `Idle` (4-6 frames)
    2. `Run` (6-8 frames)
    3. `LightAttack_Combo1` (4 frames)
    4. `LightAttack_Combo2` (4 frames)
    5. `HeavyAttack` (6 frames)
    6. `Skill_Cast` (5 frames)
    7. `Dash_IFrame` (4 frames)
    8. `Hurt` (2 frames)
    9. `Death` (8 frames)

### 2.2 Pipeline Técnico de Renderizado (Godot 4.x)
1. **Configuración de Viewport y Escalado:**
   * `Project Settings > Display > Window`: `Viewport Width/Height` = **1280 × 720**.
   * `Stretch > Mode` = `canvas_items`, `Stretch > Aspect` = `keep`, `Stretch > Scale Mode` = `fractional` (a diferencia de un pipeline pixel art, no se busca escalado entero — los sprites pintados escalan suavemente sin artefactos).
   * `Rendering > Textures > Canvas Textures > Default Texture Filter` = `Linear` a nivel proyecto, con `Mipmaps = On` en la configuración de importación de atlas de sprites (`.import`) para evitar aliasing al alejar la cámara.
   * `Texture Compression`: `VRAM Compressed` (o `Lossless` si se prioriza fidelidad de color sobre tamaño de build) — ya no hay bordes de píxel que proteger de artefactos de compresión.
2. **Iluminación Dinámica 2D:**
   * **CanvasModulate:** Controla el tinte/iluminación ambiental global del bioma (ej. tonos azulados y oscuros para ruinas ancestrales, dorados cálidos para bosques), equivalente a la Global Light 2D de Unity.
   * **PointLight2D:** Adjuntado a antorchas, hechizos mágicos, objetos de loot brillante y el arma del personaje — clave para el look dramático de la referencia visual (antorchas cálidas contra piedra oscura).
   * **DirectionalLight2D / PointLight2D con textura cónica:** Para conos de visión de magias o rayos de luz solar atravesando copas de árboles.
   * **LightOccluder2D + Normal Maps:** `LightOccluder2D` proyecta sombras 2D desde muros y props; el `normal_map` de cada `Sprite2D`/`AnimatedSprite2D` da relieve a muros de piedra y armaduras al ser iluminados lateralmente por proyectiles o antorchas.
3. **Efectos Visuales (VFX 2D):**
   * `GPUParticles2D` con `texture_filter = Linear` — brillos de arma, chispas de impacto y partículas de alma con bordes suaves (no pixelados), consistente con el filo luminoso de la espada en la referencia visual.
   * Shaders de daño: **Flash Blanco (Hit Flash Shader)** implementado como `canvas_item` shader (`.gdshader`) con un uniform `flash_amount: float`, asignado vía `ShaderMaterial` al `material` del sprite y controlado desde código con `set_shader_parameter("flash_amount", value)` cuando la entidad recibe un impacto.

---

## 3. Arquitectura del Sistema de Combate 2D & Cosecha de Almas

### 3.1 Detección de Colisiones Orientada a Frame Data (Hitbox & Hurtbox)
Para garantizar un combate táctil y preciso similar al de los juegos de pelea o ARPGs competitivos:

* **Separación de Componentes:**
  * **Hurtbox:** `Area2D` + `CollisionShape2D` en `collision_layer = "hurtbox"` que define la zona donde el personaje/enemigo recibe daño.
  * **Hitbox:** `Area2D` + `CollisionShape2D` (nodo hijo `Hitbox`, `monitoring = true`) que se activa únicamente durante los cuadros de ataque activos, detectando `hurtbox`es vía `area_entered`.
  * Durante el Dash, el Hurtbox cambia su `collision_layer` a `"invulnerable"` en vez de `"hurtbox"`, ignorando toda detección de Hitboxes enemigas.
* **Control de Animación e Interpolación:**
  * En el `AnimationPlayer`, la activación/desactivación de la Hitbox se controla con un **Call Method Track** que invoca `hitbox.set_active(true/false)` en los frames exactos de inicio/fin de la ventana activa (equivalente a la interpolación **Constant** de Unity: sin transiciones suaves entre estados).
* **Estructura de Datos de Ataque (`Resource` personalizado `AttackData`):**
```gdscript
# scripts/data/attack_data.gd
extends Resource
class_name AttackData

enum ElementType { PHYSICAL, FIRE, FROST, SHADOW, BLOOD }

@export var attack_name: String = ""
@export var base_damage_multiplier: float = 1.0
@export var knockback_force: float = 5.0
@export var stagger_duration: float = 0.2
@export var active_frame_start: int = 2
@export var active_frame_end: int = 4
@export var element_type: ElementType = ElementType.PHYSICAL
@export var hit_vfx_scene: PackedScene
@export var hit_sfx: AudioStream
```

### 3.2 Mecánicas Clave de Combate
* **Dash / Esquiva con Frames de Invulnerabilidad (I-Frames):**
  * Al presionar la tecla de esquiva (Barra Espaciadora / Botón B), el personaje realiza un desplazamiento veloz de **12 a 16 frames**.
  * Durante los frames 2 al 12, el personaje cambia la capa de su Hurtbox a `Invulnerable`, ignorando todo daño y proyectiles.
  * Posee un tiempo de recarga (Cooldown) de 1.2 segundos o un consumo de estamina.
* **Cancelación de Animación (Animation Canceling):**
  * Los jugadores pueden cancelar los cuadros de recuperación de un ataque básico activando inmediatamente un **Dash** o una **Habilidad Especial**, permitiendo encadenar combos ágiles y esquivar ataques enemigos de último segundo.
* **Matemática de Empuje (Knockback & Stagger):**
  $$\text{VectorEmpuje} = \text{DirecciónImpacto} \times \left( \frac{\text{KnockbackForce}}{\text{MasaObjetivo}} \right)$$
  * Si la fuerza de impacto supera el umbral de aplomo (*Stagger Threshold*) del enemigo, este entra en un estado de interrupción momentánea de acción.

### 3.3 Mecánica Insignia: Cosecha de Almas (Soul Harvest)
Cada enemigo derrotado en el mundo suelta de 1 a 5 **Orbes de Esencia de Alma**.

```
  [ Enemigo Derrotado ]
           │
           ▼ (Instancia Orbe de Alma 2D)
  [ Modificador de Atracción ] ──► Distancia < 4 Unidades ──► Vuelo hacia Jugador
                                                                    │
                                                                    ▼
                                                       [ Medidor de Almas ++ ]
                                                                    │
                                      ┌─────────────────────────────┴─────────────────────────────┐
                                      ▼                                                           ▼
                        [ Consumo de Cargas de Alma ]                               [ Modo Furia Rúnica (100%) ]
                        (Ejecución de Definitivas)                                  (+25% Vel. Ataque, +15% Robo Vida)
```

### 3.4 Sistema Insignia de Forja Rúnica de Almas (Soul-Crafting)
Inspirado en la libertad de creación de *Echoes of Mystralia*, Reaper incorpora el **Sistema de Soul-Crafting**, permitiendo al jugador forjar habilidades únicas combinando Runas de Almas cosechadas.

> **Relación con el Skill Tree (Sección 5) — resuelta en `REAPER_DIRECTION_ANALYSIS.md`:** el Skill Tree y el Soul-Crafting NO son dos fuentes paralelas de habilidades activas. **El Skill Tree otorga poder pasivo y *slots* de runa activa; el Soul-Crafting define qué hace cada slot.** Los nodos activos de una rama (ej. Tier 1 y Tier 3 de la Rama A) dejan de ser una habilidad fija con nombre propio y pasan a ser el desbloqueo de un **Slot de Runa Activa** / **Slot de Runa de Movilidad** — ver la Sección 5.1 actualizada. Los Keystones (Tier 5) sí quedan fijos: un Hito Maestro espectacular no necesita ser modular.
>
> **Adquisición de runas:** las runas se desbloquean/craftean gastando **Esencia de Alma** (el mismo medidor de `SoulHarvestManager`, GDD Sección 3.3) en un **Altar de Almas** — no se introduce una moneda nueva. Esto le da un uso permanente a las almas cosechadas más allá de la Furia Rúnica temporal.
>
> **Alcance del prototipo (Hito 7-8):** empezar chico a propósito — **3 Runas de Forma × 2 Runas de Modificador × 2 Runas de Trigger** (12 combinaciones, no "infinitas"). Cada combinación se diferencia por *números* (daño, radio, duración, knockback) reusando el `Hitbox`/`AttackData` ya construido, no con VFX únicos por combinación — evita el riesgo de que un sistema combinatorio requiera arte que hoy no existe.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   FORJA RÚNICA DE ALMAS (SOUL-CRAFTING)                 │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Runa de Ejecución (Forma): Tajo Giro, Guadaña Espectral, Nova.      │
│ 2. Runa de Modificador (Efecto): Vampirismo, Ceniza doT, Succión.      │
│ 3. Runa de Desencadenante (Trigger): Al Asestar Crítico, Al Esquivar.  │
└────────────────────────────────────────────────────────────────────────┘
```

#### Capas de Composición Rúnica:
1. **Runa de Ejecución / Forma (Shape):** Define el patrón espacial y visual del ataque (Barrido de Guadaña, Proyectil Volador, Nova Terrestre, Grieta).
2. **Runa de Modificador de Alma (Modifier):** Altera los atributos del impacto (Sed de Sangre, Daño por Quemadura de Ceniza, Succión Centrípeda, Penetración).
3. **Runa de Desencadenante / Trigger:** Define condiciones de disparo automático (*"Al matar enemigo"*, *"Al esquivar con Dash"*, *"Al acertar golpe crítico"*).

#### Implementación GDScript (`RuneData` & `RuneSpellBuilder`):
```gdscript
# scripts/data/rune_data.gd
extends Resource
class_name RuneData

enum RuneCategory { SHAPE, MODIFIER, TRIGGER }
enum SoulElement { SHADOW, FIRE, FROST, BLOOD, VOID }

@export var rune_id: String = ""
@export var rune_name: String = ""
@export_multiline var description: String = ""
@export var category: RuneCategory = RuneCategory.SHAPE
@export var element: SoulElement = SoulElement.SHADOW
@export var damage_modifier: float = 1.0
@export var mana_cost_delta: float = 0.0
@export var cooldown_delta: float = 0.0
@export var vfx_override: PackedScene
```

---

## 4. Planificación de Progresión Completa y Economía de Stats

### 4.1 Curva de Experiencia y Escalado de Niveles
* **Cap de Niveles Base:** **Nivel 50**.
* **Sistema Ancestral (Post-Level 50):** Al alcanzar el Nivel 50, la experiencia acumulada continúa otorgando **Puntos Ancestrales** ilimitados que pueden invertirse en pequeños incrementos de estadísticas secundarias (+0.1% Daño, +5 HP, +0.1% Velocidad).
* **Fórmula de Experiencia Requerida por Nivel:**
  $$\text{XP\_Requerida}(L) = 100 \times (L^{2.15}) + 150 \times L$$

| Nivel | XP Necesaria (Nivel) | XP Acumulada Total | Recompensa al Subir |
| :---: | :---: | :---: | :--- |
| **1** | 0 | 0 | Estado Inicial |
| **2** | 250 | 250 | +3 Puntos de Stat, +1 Punto de Habilidad |
| **5** | 2,850 | 6,400 | Desbloqueo de Rama Secundaria |
| **10** | 18,200 | 45,100 | Desbloqueo de Ranura Rúnica I |
| **25** | 165,000 | 820,000 | Desbloqueo de Habilidad Definitiva (Tier 5) |
| **50** | 1,450,000 | 12,500,000 | Cap Base alcanzado. Desbloqueo de *Modo Ancestral* |

### 4.2 Atributos Principales y sus Fórmulas Exactas
Al subir de nivel, el jugador obtiene **3 Puntos de Atributos** para distribuir libremente:

1. **Fuerza (STR):**
   * $+2.0$ Daño Físico Cuerpo a Cuerpo por punto.
   * $+0.75$ Armadura Física por punto.
   * $+0.15\%$ Resistencia a Interrupciones (Stagger) por punto.
2. **Agilidad (AGI):**
   * $+0.25\%$ Probabilidad de Golpe Crítico por punto.
   * $+0.30\%$ Velocidad de Ataque y Animaciones de Combate por punto.
   * $+0.15\%$ Velocidad de Movimiento por punto.
3. **Inteligencia (INT):**
   * $+2.5$ Daño de Magia / Elementos (Fuego, Escarcha, Sombra) por punto.
   * $+6.0$ Maná Máximo por punto.
   * $+0.40\%$ Resistencia Elemental por punto.
4. **Vigor (VIG):**
   * $+15.0$ Salud Máxima (HP) por punto.
   * $+0.50$ Regeneración de Salud por segundo por punto.
   * $+0.20\%$ Reducción de Daño General por punto.
5. **Afinidad Rúnica (RUN):**
   * $+0.35\%$ Reducción de Tiempos de Recarga (Cooldown Reduction) por punto.
   * $+1.50\%$ Eficiencia y Radio de Atracción de Cosecha de Almas por punto.
   * $+0.80\%$ Potencia de Efectos Modificadores de Runas por punto.

---

### 4.3 Sistema de Loot e Itemización ARPG

#### Jerarquía de Raridades de Objetos
1. **Común (Gris/Blanco):** Sin afijos mágicos. 0 Ranuras rúnicas.
2. **Mágico (Verde):** 1 Prefijo y 1 Sufijo aleatorios. 0-1 Ranuras.
3. **Raro (Azul):** 2 Prefijos y 2 Sufijos aleatorios. 1 Ranura rúnica garantizada.
4. **Rúnico / Épico (Púrpura):** 3 Prefijos y 3 Sufijos con valores elevados. 2 Ranuras rúnicas.
5. **Ancestral / Legendario (Naranja):** Stats fijos temáticos + 1 **Efecto Único Legendario** + 2 a 3 Ranuras rúnicas.

---

## 5. Árboles de Habilidades Exhaustivos (Skill Trees) por Clase

Cada clase posee 3 Ramas Especializadas. Los jugadores reciben **1 Punto de Habilidad por Nivel** (49 Puntos en Total al Nivel 50).

---

### 5.1 Clase: Cosechador (Reaper)

```
                                  [ CLASE: COSECHADOR ]
                                            │
        ┌───────────────────────────────────┼───────────────────────────────────┐
        ▼                                   ▼                                   ▼
[ RAMA A: Sombras ]               [ RAMA B: Ejecutor ]                [ RAMA C: Pacto ]
(Doble Guadaña/Velocidad)         (Guadaña 2H/Daño Pesado)            (Siphon/Esencia/Soporte)
```

#### RAMA A: Cosechador de Sombras (Velocidad, Robo de Vida & Agilidad)
* **Tier 1 (Req. Nivel 1) — Desbloquea Slot de Runa Activa:** el contenido del slot lo define la runa de Forma que el jugador craftee ahí (Soul-Crafting, Sección 3.4) — ej. equipado con Forma "Guadaña Espectral" + Modificador "Vampirismo" se comporta como la antigua *Danza de las Hojas Sombrías* (ráfaga de cortes giratorios, daño físico/sombra), pero es una de varias combinaciones posibles, no una habilidad fija.
* **Tier 2 (Nodo Pasivo):** *Cuchillas Voraces* - Cura al Cosechador un $2\% + (1\% \times \text{Nivel})$ del daño infligido al asestar golpes críticos.
* **Tier 3 (Req. 8 pts en rama) — Desbloquea Slot de Runa de Movilidad:** por defecto equivalente a *Paso Espectral* (teletransporte detrás del enemigo más cercano, invisibilidad 2s), pero craftable con otras combinaciones de Forma/Trigger de movilidad.
* **Tier 4 (Nodo Pasivo):** *Seducción de la Oscuridad* - Incrementa la velocidad de ataque un $3\%$ por cada enemigo cercano afectado por sangrado.
* **Tier 5 (Keystone, fijo — no modular):** *Frenesí de Almas Desatadas* - Estado de avatar sombrío por 10s: +40% Vel. Movimiento, Dash sin cooldown y ataques críticos garantizados.

---

## 6. Sistemas Endgame y Loop de Juego

### 6.1 Fisuras Rúnicas (Ancestral Rifts)
Las Fisuras Rúnicas representan el contenido principal de endgame para probar builds de personajes (inspirado en *Echoes of Mystralia*):
* **Generación Procedural:** Algoritmos de Tilemaps aleatorios que combinan salas de mazmorras, pasillos de ruinas y hordas de monstruos.
* **Modificadores de Fisura (Affixes):**
  * *Suelo Magmático:* Zonas de lava periódicas.
  * *Drenaje Rúnico:* Maná se drena 2% por segundo.
  * *Horda Enloquecida:* Enemigos con +50% de velocidad de ataque.
* **Medidor de Progresión:** Derrotar enemigos llena la barra de fisura. Al llegar al 100%, aparece el **Guardián de la Fisura** (Boss con mecánicas únicas).

### 6.2 Cacería de World Bosses 2D (restaurada — objetivo del Hito 11+, ver Sección 9)
* **Telegrafiado Rojo (Indicator System):** Áreas rojas transparentes que alertan al jugador 1.5s antes de un ataque masivo.
* **Fases del Boss:** Al llegar al 50% de vida, el boss cambia de color (Shader Tint), desbloquea nuevos ataques de área y entra en frenesí.
```
       [ Fase 1: Ataques Básicos y Embestidas ]
                          │
                          ▼ (Vida < 50%)
       [ Fase 2: Transición - Shader Flash & Invulnerabilidad ]
                          │
                          ▼
       [ Fase 3: Telegrafiados Rojos Masivos & Lluvia de Proyectiles ]
```
* **Primer candidato concreto:** un Treant reescalado (2x tamaño actual, más HP, ataque de área en vez de golpe simple) — reusa el sprite/enemigo ya construido en vez de requerir arte nuevo, coherente con el criterio de alcance de la Sección 5 de `REAPER_DIRECTION_ANALYSIS.md`.

---

## 7. Arquitectura Técnica de Código en Godot 4.x

### 7.1 Estructura de Componentes en GDScript

```
res://
├── docs/
│   ├── GDD_Las_Cronicas_de_Reaper_2D_PixelArt_ARPG.md # Documento Maestro de Diseño
│   ├── ECHOES_OF_MYSTRALIA_ANALYSIS.md                # Análisis estratégico de Mystralia
│   └── REAPER_DIRECTION_ANALYSIS.md                   # Resolución de tensiones Skill Tree vs Soul-Crafting, roadmap
├── autoloads/
│   ├── game_manager.gd            # Autoload: estado global de partida
│   └── sound_manager.gd           # Autoload: música y SFX
├── scripts/
│   ├── core/
│   │   └── pixel_perfect_utils.gd
│   ├── combat/
│   │   ├── hitbox.gd
│   │   ├── hurtbox.gd
│   │   ├── health_system.gd
│   │   ├── rune_spell_builder.gd  # Gestor de Soul-Crafting dinámico
│   │   └── soul_harvest_manager.gd
│   ├── data/
│   │   ├── attack_data.gd         # class_name AttackData (Resource)
│   │   ├── rune_data.gd           # class_name RuneData (Resource)
│   │   ├── stat_system.gd         # class_name StatSystem (Node)
│   │   ├── skill_node_data.gd     # class_name SkillNodeData (Resource)
│   │   └── item_data.gd           # class_name ItemData (Resource)
│   ├── skill_tree/
│   │   ├── skill_tree_manager.gd
│   │   └── skill_node_ui.gd
│   └── ui/
│       ├── hud_controller.gd
│       └── floating_damage_spawner.gd
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── ui/
│   └── levels/
├── resources/
│   ├── attacks/                   # instancias .tres de AttackData
│   ├── runes/                     # instancias .tres de RuneData (Soul-Crafting)
│   ├── items/                     # instancias .tres de ItemData
│   └── skills/                    # instancias .tres de SkillNodeData
└── art/
    ├── sprites/
    ├── shaders/
```

---

## 8. Buenas Prácticas e Insights de Desarrolladores (Game Dev Forums)

### 8.1 Game Juice (Retroalimentación Visual y Táctil)
1. **Hitstop / Micro-Pausas (Freeze Frames):** Congela `Time.timeScale` a `0.0f` durante 2 a 4 frames (0.03s a 0.06s) en impactos pesados o críticos.
2. **Screen Shake Direccional:** La cámara tiembla en la dirección opuesta al impacto mediante perfiles de ruido Perlin.
3. **Flashing de Daño (Hit Flash Shader):** El sprite se vuelve blanco uniforme durante 1 frame tras recibir daño.
4. **Números de Daño Flotantes (Floating Combat Text):** Números emergentes con tipografía limpia y rebote visual para críticos.

---

## 9. Próximas Etapas de Desarrollo (Hoja de Ruta)

- [x] **Hito 1:** Documento Maestro de Diseño 2D ARPG completado (`docs/GDD_Las_Cronicas_de_Reaper_2D_PixelArt_ARPG.md`).
- [x] **Hito 1.5:** Pivot de motor: arquitectura técnica migrada a **Godot 4.x**.
- [x] **Hito 2:** Configuración del proyecto Godot (Viewport 1280x720, escalado fraccional, Autoloads base y Hit Flash shader).
- [x] **Hito 2.5:** Pivot de dirección de arte a estilo pintado/chibi de alta resolución (Secciones 1.4 y 2.1).
- [x] **Hito 3 (Vertical Slice):** Loop mínimo jugable — Ataque con Hitbox real, daño calculado vía StatSystem, muerte de enemigo y recolección de Orbes de Alma al HUD.
- [x] **Hito 4:** IA de persecución/ataque en `Enemy` y daño real sobre el Player.
- [x] **Hito 5:** Animaciones reales del Player (`AnimatedSprite2D` + `hero_sprite_frames.tres`).
- [x] **Hito 6:** UI del Árbol de Habilidades (tecla **K**) con validación de puntos y dependencias de nodos.
- [x] **Hito 6.5:** Organización de documentación en `docs/` e integración del **Sistema de Forja Rúnica de Almas (Soul-Crafting)** inspirado en *Echoes of Mystralia*. Resuelta la tensión de diseño con el Skill Tree (`REAPER_DIRECTION_ANALYSIS.md`, 2026-08-11): Skill Tree = poder pasivo + slots, Soul-Crafting = contenido de esos slots.
- [ ] **Hito 7:** `RuneData` (Resource) + 3 Runas de Forma + 2 de Modificador + 2 de Trigger reales (`resources/runes/`) + `RuneSpellBuilder` que compone un `AttackData` temporal a partir de 1-3 runas equipadas. Sin UI todavía — probado por escena de debug antes de invertir en interfaz.
- [ ] **Hito 8:** Altar de Almas (UI) — gastar Esencia de Alma (`SoulHarvestManager`) para desbloquear runas y equiparlas en los Slots de Runa Activa/Movilidad (Tier 1 y Tier 3 del Skill Tree, Sección 5.1).
- [ ] **Hito 9:** Persistencia de estado de Chunks y enemigos derrotados (el "Hito 7" original antes de esta actualización de roadmap).
- [ ] **Hito 10:** Segundo tipo de enemigo con ataque a distancia — variedad de amenaza antes de variedad de clases.
- [ ] **Hito 11+:** Primer World Boss (telegrafiado + fases, Sección 6.2), usando Treant reescalado como base — primer objetivo de "final" del vertical slice.
