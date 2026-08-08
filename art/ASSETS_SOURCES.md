# Fuentes de assets placeholder

Assets temporales para poder jugar/probar mientras no tengamos el arte pintado/chibi definitivo (ver `WhatsApp Image 2026-08-08 at 16.45.48.jpeg` en la raíz del proyecto como referencia de estilo final).

## Ya descargados en este repo

| Carpeta | Fuente | Licencia | Uso |
|---|---|---|---|
| `art/ui/kenney_ui_pack_rpg/` | [Kenney — UI Pack (RPG Expansion)](https://kenney.nl/assets/ui-pack-rpg-expansion) | CC0 (sin atribución requerida) | Barras de vida/maná, marcos de skill slots — placeholder del HUD |
| `art/ui/kenney_ui_pack/` | [Kenney — UI Pack](https://kenney.nl/assets/ui-pack) | CC0 | Botones, paneles, sliders genéricos para menús |
| `art/environment/tiny_rpg_forest/` | [Tiny RPG Forest by Luis Zuno (ansimuz)](https://opengameart.org/content/tiny-rpg-forest) — OpenGameArt | CC0 / dominio público (crédito no obligatorio) | Árboles (naranja/rosa/seco), arbustos, rocas, tronco, cartel — usados en `scenes/main/main.tscn` para el entorno boscoso. El pack también trae un héroe arquero animado y enemigos **Treant** y **Mole** (no usados todavía, quedan en el zip original para cuando armemos enemigos) |

## Pendientes de descarga manual (requieren cuenta/click en el sitio)

No se pudieron descargar automáticamente porque el botón de descarga depende de una sesión de navegador (itch.io) o de una API con auth (Freesound) — bajarlos manualmente toma 1 click:

| Assets | Fuente | Licencia | Nota |
|---|---|---|---|
| SFX (espadas, hechizos, pasos, puertas — 200+ sonidos) | [TomMusic — Free Fantasy 200 SFX Pack](https://tommusic.itch.io/free-fantasy-200-sfx-pack) (itch.io, "pagá lo que quieras", $0 posible) | Royalty-free, uso comercial permitido, atribución no obligatoria, **no redistribuir el paquete original** | Bajar y descomprimir en `art/audio/sfx/` |
| SFX masivos (347 WAV, 7.4GB) | [Sonniss GDC 2026 Game Audio Bundle](https://gdc.sonniss.com/) | Royalty-free, sin atribución, uso comercial ilimitado de por vida | Grande — bajar solo si hace falta variedad extra |
| SFX puntuales (espadazos, impactos) | [Freesound.org](https://freesound.org) — ej. [Sword Clashes Pack de JohnBuhr](https://freesound.org/people/JohnBuhr/packs/18347/) | Varía por track (CC0/CC-BY) — **revisar cada licencia individual** | Requiere cuenta gratuita de Freesound para descargar |

> **Nota de estilo:** el pack de bosque es pixel art 16x16 (escalado x1.5-2 en la escena), no el estilo pintado/chibi definitivo — es el placeholder "opción 1" descrito abajo, elegido porque no encontramos ningún tileset de bosque *pintado* realmente gratuito y descargable. Sirve para tener un entorno real navegable mientras se resuelve el arte final.

## Sin match gratuito bueno — arte de personajes/enemigos/tileset pintado

Busqué específicamente packs **pintados/chibi de alta resolución** (el estilo de la referencia) en itch.io y CraftPix: casi todo lo gratuito en esa categoría es **pixel art de grilla baja** (16x16/32x32), que no calza con la dirección de arte elegida (ver GDD sección 2.1). CraftPix sí tiene packs pintados pero son de pago.

Dos caminos, no mutuamente excluyentes:
1. **Placeholders pixel art gratuitos** (funcionales, NO de estilo final) solo para probar colisiones/animaciones/gameplay — ej. [CraftPix — Free Top-Down Roguelike Game Kit](https://craftpix.net/freebies/free-top-down-roguelike-game-kit-pixel-art/), [Free Top-Down Boss Character 4-Direction Pack](https://craftpix.net/freebies/free-top-down-boss-character-4-direction-pack/). Marcar claramente como TEMP para que nadie los confunda con arte final.
2. **Generar placeholders con IA** en el estilo exacto de la referencia (Midjourney / Leonardo.ai / Scenario.gg) — más lento por sprite pero visualmente coherente con el target. Recomendado para el personaje jugable y 1-2 enemigos clave, ya que son lo primero que se ve/prueba.

## Licencias — recordatorio

Antes de publicar/vender el juego, revisar la licencia de cada asset usado (algunos packs "gratis" son solo para uso no comercial). Los Kenney packs (CC0) y los packs de Sonniss no tienen esta restricción.
