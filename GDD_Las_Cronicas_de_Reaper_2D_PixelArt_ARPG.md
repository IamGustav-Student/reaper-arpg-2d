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
* **Eternium & Diablo Immortal (versión móvil):** Referentes en HUD de combate (orbes de Vida/Maná, barra de habilidades inferior) y en cómo un estilo pintado de alto detalle se integra con partículas y efectos de arma brillante.
* **Bastion:** Referente en atmósfera de mazmorra pintada, paletas cálidas de antorchas contra piedra oscura, y cámara fija 3/4 que enmarca el combate.
* **The Slormancer & Chronicon:** Referentes en profundidad de árboles de habilidades, personalización de build, recolección de loot y escalabilidad de números en endgame.
* **Children of Morta:** Referente en la animación frame-by-frame narrativa y el impacto de los efectos visuales en combates contra hordas (independiente del estilo de arte final).

> **Nota (2026-08-08):** el proyecto pivotó de Pixel Art de grilla baja a un estilo **pintado/chibi de mayor resolución** (ver imagen de referencia `WhatsApp Image 2026-08-08 at 16.45.48.jpeg`), manteniendo intactos el core loop, sistema de combate, stats, skill trees y loot del resto de este documento — el cambio es puramente de dirección de arte y su pipeline técnico asociado (Secciones 1.4 y 2).

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

enum ElementType { PHYSICAL, FIRE, FROST, SHADOW }

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
Se crean instancias como archivos `.tres` (`Recurso Nuevo > AttackData` desde el editor de Godot), equivalente directo al flujo `CreateAssetMenu` de Unity.

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

#### Generación de Afijos (Ejemplo de Tabla de Prefijos y Sufijos)

```
                       ┌────────────────────────────────────────┐
                       │  Generación de Objeto Raro (Ej. Casco) │
                       └───────────────────┬────────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    ▼                                             ▼
       [ Prefijos (Hasta 2) ]                        [ Sufijos (Hasta 2) ]
       • +25 HP Máxima (Vigoroso)                    • +3% Prob. Crítico (del Asesino)
       • +12 Armadura (Inflexible)                   • +5% Reducción Cooldowns (Rúnico)
```

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
* **Tier 1 (Nodo Activo - Req. Nivel 1):**
  * **Nombre:** *Danza de las Hojas Sombrías*
  * **Nivel Máx:** 5 | **Costo Maná:** 15
  * **Efecto:** Ejecuta una ráfaga de 3 cortes giratorios que dañan a todos los enemigos a su alrededor infligiendo $80\% + (10\% \times \text{Nivel})$ de daño físico y de sombra.
* **Tier 2 (Nodo Pasivo - Req. 3 Puntos en Rama):**
  * **Nombre:** *Cuchillas Voraces*
  * **Nivel Máx:** 5
  * **Efecto:** Cura al Cosechador un $2\% + (1\% \times \text{Nivel})$ del daño infligido al asestar golpes críticos.
* **Tier 3 (Nodo Activo - Req. 8 Puntos en Rama):**
  * **Nombre:** *Paso Espectral*
  * **Nivel Máx:** 3 | **Cooldown:** 8s
  * **Efecto:** Se teletransporta detrás del enemigo más cercano, volviéndose invisible durante 2 segundos y aumentando la probabilidad de crítico del siguiente ataque en un $50\%$.
* **Tier 4 (Nodo Pasivo - Req. 15 Puntos en Rama):**
  * **Nombre:** *Seducción de la Oscuridad*
  * **Nivel Máx:** 5
  * **Efecto:** Incrementa la velocidad de ataque un $3\%$ por cada enemigo cercano afectado por sangrado (acumulable hasta 5 veces).
* **Tier 5 (Hito Maestro / Keystone - Req. 20 Puntos en Rama):**
  * **Nombre:** *Frenesí de Almas Desatadas*
  * **Nivel Máx:** 1 | **Cooldown:** 45s | **Costo:** 100% Medidor de Almas
  * **Efecto:** Entra en un estado de avatar sombrío durante 10 segundos. La velocidad de movimiento sube $+40\%$, el Dash no tiene cooldown y todos los ataques asestan daño crítico de sombra.

#### RAMA B: Ejecutor Nigromántico (Impacto Pesado, Control & Caos)
* **Tier 1 (Nodo Activo):** *Tajo de la Guadaña Ancestral* - Gran barrido frontal de 180° que empuja a los enemigos e inflige $150\%$ de daño.
* **Tier 2 (Nodo Pasivo):** *Armadura de Ceniza* - Al infligir daño pesado, gana un escudo equivalente al $5\%$ de la vida máxima durante 4 segundos.
* **Tier 3 (Nodo Activo):** *Onda de Decadencia* - Clava la guadaña en el suelo liberando una grieta de sombra que reduce la armadura de los enemigos en un $25\%$ por 6 segundos.
* **Tier 4 (Nodo Pasivo):** *Sentencia del Verdugo* - Los enemigos con menos del $30\%$ de HP reciben un $40\%$ más de daño de todos tus ataques.
* **Tier 5 (Keystone):** *Invocación de la Guadaña del Vacío* - Invoca una guadaña gigante del plano espectral que cae del cielo, aturdiendo a todos los enemigos en pantalla durante 3 segundos e infligiendo daño masivo de sombra.

#### RAMA C: Pacto de las Almas (Cosecha, Drenaje & Utilidad)
* **Tier 1 (Nodo Activo):** *Drenaje de Esencia* - Conecta un rayo de alma a un objetivo, drenando HP por segundo y recargando el Medidor de Almas.
* **Tier 2 (Nodo Pasivo):** *Magnetismo del Abismo* - Aumenta el radio de atracción de los orbes de alma en un $+100\%$ y otorga $+5$ de maná por orbe recogido.
* **Tier 3 (Nodo Activo):** *Santuario de las Almas Caídas* - Coloca un círculo rúnico en el suelo que cura a los aliados y daña a los enemigos dentro del área.
* **Tier 4 (Nodo Pasivo):** *Pacto de Resurrección Rúnica* - Si el jugador sufre daño fatal, consume todo el medidor de almas para revivir instantáneamente con el $50\%$ de vida (Cooldown: 180s).
* **Tier 5 (Keystone):** *Cosecha Arcana Suprema* - Detona todos los orbes de almas en el suelo, creando explosiones en cadena que otorgan invulnerabilidad temporal al Cosechador.

---

### 5.2 Clase: Caballero Guardián

#### RAMA A: Fortaleza Inquebrantable (Tanque Puro & Bloqueo)
* **T1 (Activo):** *Golpe de Escudo de Torre* - Impacto frontal que aturde al objetivo por 1.5s y genera alta amenaza.
* **T2 (Pasivo):** *Postura Inflexible* - Incrementa la probabilidad de bloqueo con escudo en un $+15\%$ y reduce el daño recibido por la espalda en $+20\%$.
* **T3 (Activo):** *Provocación Inmortal* - Lanza un rugido que fuerza a todos los enemigos en 5 metros a atacar al Caballero y otorga $+30\%$ de armadura.
* **T4 (Pasivo):** *Baluarte de Piedra* - Convierte un $10\%$ de la Armadura total en Daño Físico adicional.
* **T5 (Keystone):** *Muro del Reino Alba* - Se vuelve completamente inmune a todo daño e interrupciones durante 5 segundos.

#### RAMA B: Vengador del Temple (Contraataque & Mandoble)
* **T1 (Activo):** *Carga del Temple* - Embestida veloz hacia adelante que arrastra a los enemigos en su camino.
* **T2 (Pasivo):** *Espines de Hierro* - Devuelve el $25\%$ del daño recibido al atacante como daño físico.
* **T3 (Activo):** *Sentencia de Acero* - Un corte descendente con mandoble que rompe el suelo e inflige daño crítico garantizado si el enemigo está aturdido.
* **T4 (Pasivo):** *Furia del Vengador* - Ganar $+2\%$ de daño de ataque por cada $5\%$ de vida perdida.
* **T5 (Keystone):** *Juicio Divino de la Forja* - Salta por los aires y cae aplastando el terreno con una explosión sagrada en área de 360°.

#### RAMA C: Comandante Radiante (Auras & Soporte de Batalla)
* **T1 (Activo):** *Aura del Alba* - Aura activa que otorga $+15\%$ de velocidad de movimiento a los aliados cercanos.
* **T2 (Pasivo):** *Inspiración Caballeresca* - Reduce los tiempos de recarga de todas las habilidades de la party en un $10\%$.
* **T3 (Activo):** *Estandarte del Reino* - Clava un estandarte sagrado que crea una zona de curación constante y resistencia a estados alterados.
* **T4 (Pasivo):** *Bendición de la Luz Rúnica* - Los ataques del Caballero aplican una marca que cura a cualquier aliado que dañe al objetivo marcado.
* **T5 (Keystone):** *Presencia del Comandante Invicto* - Convoca a la vanguardia de caballeros fantasmas que cargan en fila india limpiando la pantalla de enemigos.

---

### 5.3 Clase: Mago Rúnico / Taumaturgo

#### RAMA A: Tejedura del Fuego y Tormenta (DPS Elemental AoE)
* **T1 (Activo):** *Orbe del Fuego Caótico* - Lanza una bola de fuego que explota al impacto dañando en un radio de 2 metros.
* **T2 (Pasivo):** *Combustión Rúnica* - Los hechizos de fuego dejan a los enemigos ardiendo durante 4 segundos.
* **T3 (Activo):** *Cadena de Rayos Ancestrales* - Descarga un rayo que salta entre 4 enemigos, reduciendo su velocidad de ataque.
* **T4 (Pasivo):** *Sobrecarga Magmática* - Aumenta el daño de área (AoE) en un $+25\%$.
* **T5 (Keystone):** *Cataclismo Rúnico (Meteorito)* - Invoca un meteoro gigante envuelto en runas que destruye el suelo y deja llamas abrasadoras.

#### RAMA B: Guardián de la Escarcha (Control de Masas & Barreras)
* **T1 (Activo):** *Lanza de Hielo Perforante* - Proyectil helado que atraviesa enemigos y los ralentiza un $40\%$.
* **T2 (Pasivo):** *Piel de Escarcha* - Genera una barrera de hielo constante que absorbe daño según la Inteligencia.
* **T3 (Activo):** *Nova Congelante* - Explosión helada centrada en el jugador que congela por completo a los enemigos por 2.5s.
* **T4 (Pasivo):** *Frágil como el Cristal* - Los enemigos congelados reciben un $+50\%$ de daño crítico adicional.
* **T5 (Keystone):** *Cero Absoluto* - Detiene el tiempo y la animación de todos los enemigos en la pantalla durante 4 segundos.

#### RAMA C: Alquimia del Vacío y la Vida (DoTs, Drenaje & Maná)
* **T1 (Activo):** *Orbe de Siphon Arcano* - Invoca un vórtice que atrae enemigos pequeños hacia su centro mientras drena maná.
* **T2 (Pasivo):** *Flujo de Maná Infinito* - Regenera maná al matar enemigos y reduce los costos de hechizos.
* **T3 (Activo):** *Distorsión Espacial* - Crea un portal de teletransporte corto para esquivar y posicionarse.
* **T4 (Pasivo):** *Alquimia Corrupta* - Convierte el $20\%$ del daño mágico en daño de veneno continuo.
* **T5 (Keystone):** *Singularidad Rúnica del Vacío* - Crea un agujero negro en el centro de la pantalla que succiona a todos los enemigos y los detona al finalizar.

---

### 5.4 Clase: Cazador de Sombras

#### RAMA A: Tirador de Precisión (Rango & Velocidad)
* **T1 (Activo):** *Disparo Perforante* - Dispara una flecha de alta velocidad que atraviesa hasta 3 enemigos.
* **T2 (Pasivo):** *Ojo del Rastreador* - Aumenta la distancia de visión y el daño infligido a enemigos lejanos en $+20\%$.
* **T3 (Activo):** *Lluvia de Flechas Rúnicas* - Dispara al cielo para hacer caer una granizada de flechas sobre una zona.
* **T4 (Pasivo):** *Munición Encantada* - Los ataques básicos tienen un $20\%$ de probabilidad de lanzar una flecha extra sin costo.
* **T5 (Keystone):** *Disparo del Juicio Final* - Carga un disparo único atravesador de pantalla que inflige daño masivo en línea recta.

#### RAMA B: Maestro de Trampas (Control & Daño Implícito)
* **T1 (Activo):** *Trampa de Espinas Venenosas* - Coloca una trampa invisible en el suelo que inmoviliza y envenena al ser pisada.
* **T2 (Pasivo):** *Ingeniería de Caza* - Permite tener hasta 3 trampas activas simultáneamente y reduce su tiempo de armado.
* **T3 (Activo):** *Abrojos Elementales* - Esparce abrojos que ralentizan a los enemigos y les infligen sangrado.
* **T4 (Pasivo):** *Reacción en Cadena* - La activación de una trampa tiene un $30\%$ de probabilidad de armar automáticamente otra trampa cercana.
* **T5 (Keystone):** *Campo de Minas Rúnicas* - Cubre toda la zona circundante de explosivos mágicos que detonan en secuencia al entrar en combate.

#### RAMA C: Acechador Fantasma (Sigilo & Agilidad)
* **T1 (Activo):** *Capa de las Sombras* - Entra en sigilo absoluto durante 4 segundos. El primer ataque desde el sigilo es crítico garantizado.
* **T2 (Pasivo):** *Pasos Silenciosos* - Aumenta la velocidad de movimiento mientras está en sigilo o de noche en $+30\%$.
* **T3 (Activo):** *Abanico de Dagas Venenosas* - Lanza 5 dagas en cono frontal que aplican veneno acumulable.
* **T4 (Pasivo):** *Asesino Oportunista* - Matar a un enemigo reduce el tiempo de recarga de *Capa de las Sombras* a cero.
* **T5 (Keystone):** *Ejecución desde el Abismo* - Salta de sombra en sombra atacando a 5 objetivos aleatorios en menos de 1 segundo.

---

## 6. Sistemas Endgame y Loop de Juego

### 6.1 Fisuras Rúnicas (Ancestral Rifts)
Las Fisuras Rúnicas representan el contenido principal de endgame para probar builds de personajes:
* **Generación Procedural:** Algoritmos de Tilemaps aleatorios que combinan salas de mazmorras, pasillos de ruinas y hordas de monstruos.
* **Modificadores de Fisura (Affixes):**
  * *Suelo Magmático:* El mapa tiene zonas de lava periódicas.
  * *Drenaje Rúnico:* El maná se drena un 2% por segundo.
  * *Horda Enloquecida:* Los enemigos tienen +50% de velocidad de ataque.
* **Medidor de Progresión:** Derrotar enemigos llena una barra de progreso. Al llegar al 100%, aparece el **Guardián de la Fisura** (Boss con mecánicas únicas).

### 6.2 Cacería de World Bosses 2D
Los Jefes de Mundo están diseñados con patrones de telegrafiado claro en 2D Pixel Art:
* **Telegrafiado Rojo (Indicator System):** Áreas rojas transparentes en la cuadrícula que alertan al jugador 1.5 segundos antes de un ataque masivo.
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

### 6.3 Forja y Transmutación Rúnica
* **Extracción de Runas:** Permite destruir un objeto rúnico para recuperar sus gemas/runas engastadas.
* **Re-Roll de Afijos:** Consumir *Esencia de Alma* en la forja para volver a tirar los valores numéricos de los prefijos/sufijos de un equipo legendario.

---

## 7. Arquitectura Técnica de Código en Godot 4.x

### 7.1 Estructura de Componentes en GDScript
El proyecto se desarrollará utilizando una arquitectura modular guiada por señales (`Signal`) y `Resource`s personalizados, con Autoloads (Singletons) para los sistemas globales.

```
res://
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
│   │   └── soul_harvest_manager.gd
│   ├── data/
│   │   ├── attack_data.gd         # class_name AttackData (Resource)
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
│   ├── items/                     # instancias .tres de ItemData
│   └── skills/                    # instancias .tres de SkillNodeData
└── art/
    ├── sprites/
    │   ├── characters/
    │   ├── enemies/
    │   └── tilemaps/
    └── shaders/
        ├── sprite_flash.gdshader
        └── pixel_outline.gdshader
```

### 7.2 Script de Ejemplo: Gestor de Stats del Personaje (`stat_system.gd`)
```gdscript
# scripts/data/stat_system.gd
extends Node
class_name StatSystem

signal stats_recalculated

@export_group("Atributos Base")
@export var strength: int = 10
@export var agility: int = 10
@export var intelligence: int = 10
@export var vigor: int = 10
@export var runic_affinity: int = 10

@export_group("Valores Calculados", "")
var max_health: float
var physical_damage: float
var crit_chance: float
var cooldown_reduction: float

func _ready() -> void:
    recalculate_stats()

func recalculate_stats() -> void:
    max_health = 100.0 + (vigor * 15.0)
    physical_damage = 10.0 + (strength * 2.0)
    crit_chance = 5.0 + (agility * 0.25)
    cooldown_reduction = clamp(runic_affinity * 0.0035, 0.0, 0.40)

    stats_recalculated.emit()
```

---

## 8. Buenas Prácticas e Insights de Desarrolladores (Game Dev Forums)

### 8.1 Game Juice (Retroalimentación Visual y Táctil)
Basado en consensos de r/gamedev y charlas GDC de referentes 2D:

1. **Hitstop / Micro-Pausas (Freeze Frames):**
   * Al asestar un golpe crítico o un ataque pesado, la escala de tiempo (`Time.timeScale`) se congela a `0.0f` durante **2 a 4 frames** (0.03 a 0.06 segundos). Esto genera una sensación física de resistencia e impacto masivo.
2. **Screen Shake Direccional:**
   * La cámara tiembla en la dirección opuesta al vector del impacto. El temblor utiliza perfiles de ruido de Perlin (*Cinemachine Impulse Listener* o script de cámara propio) para evitar mareos visuales.
3. **Flashing de Daño (Hit Flash Shader):**
   * Todo sprite blanco se vuelve completamente blanco uniforme durante 1 frame tras ser impactado.
4. **Números de Daño Flotantes (Floating Combat Text):**
   * Números emergentes en tipografía Pixel Art. Los golpes normales se muestran en blanco/amarillo pequeño; los golpes críticos se muestran en dorado/rojo gigante con animación de rebote (Bounce scale).

### 8.2 Principios de Diseño de Interfaz (UI/UX) en Resoluciones Pixel Art
* **Fuentes Pixel-Art Nativas:** Uso de tipografías diseñadas específicamente para rejillas de píxeles sin aliasing (ej. *Crisp Pixel Font*). Evitar fuentes vectoriales suaves escaladas hacia abajo.
* **Iconografía Clara para Árboles de Habilidades:**
  * Siluetas legibles a 24x24 o 32x32 píxeles con paleta de colores distintiva:
    * **Rojo:** Habilidades Físicas/Cuerpo a Cuerpo.
    * **Azul/Violeta:** Habilidades Mágicas/Rúnicas.
    * **Verde:** Agilidad/Veno/Trampas.
    * **Dorado:** Hitos Maestros (Keystones).

---

## 9. Próximas Etapas de Desarrollo (Hoja de Ruta)

- [x] **Hito 1:** Documento Maestro de Diseño 2D ARPG completado (`GDD_Las_Cronicas_de_Reaper_2D_PixelArt_ARPG.md`).
- [x] **Hito 1.5:** Pivot de motor: arquitectura técnica migrada de Unity URP 2D a **Godot 4.x** (Secciones 2.2, 3.1 y 7).
- [x] **Hito 2:** Configuración del proyecto Godot (Viewport 1280x720, escalado fraccional, estructura de carpetas, Autoloads base y shader de Hit Flash).
- [x] **Hito 2.5:** Pivot de dirección de arte: de Pixel Art de grilla baja a estilo pintado/chibi de alta resolución (ver imagen de referencia y Secciones 1.2, 1.4, 2.1, 2.2).
- [ ] **Hito 3:** Prototipo del controlador de movimiento 2D, Dash con I-Frames e integración de Frame Data para Hitbox/Hurtbox.
- [ ] **Hito 4:** Prototipo del sistema de Cosecha de Almas (Soul Harvest) y medidor de furia.
- [ ] **Hito 5:** Creación de la UI del Árbol de Habilidades con Nodos interactivos mediante `Resource`s personalizados.
