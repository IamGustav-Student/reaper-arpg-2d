# Análisis de Echoes of Mystralia y Adaptación a Las Crónicas de Reaper

## 1. Ficha del Juego
* **Título:** Echoes of Mystralia
* **Desarrollador:** Borealys Games
* **Lanzamiento:** Agosto de 2026 (Steam Early Access)
* **Género:** ARPG Roguelite de Acción Isométrica
* **Universo:** Mystralia (Secuela/Spin-off de *Mages of Mystralia*)

---

## 2. Análisis de Mecánicas y Pilares de Diseño

### A. Creación Libre de Hechizos (*Modular Spellcrafting*)
La mayor innovación del juego radica en otorgar al jugador un kit modular de construcción de conjuros compuesto por:
1. **Forma / Emisor (Shape):** Determina cómo se manifiesta el hechizo (Proyectil, Onda Expansiva, Cono, Mina, Escudo).
2. **Comportamiento (Behavior):** Modifica la trayectoria (Rebote, Perforación, Persecución/Homing, División en abanico).
3. **Elemento (Element):** Añade la afinidad elemental (Fuego, Escarcha, Rayo, Sombra/Vacío).
4. **Desencadenante / Trigger:** Permite encadenar hechizos (*"Al matar un enemigo, detona X"*, *"Al asestar golpe crítico, invoca Y"*).

### B. Sensación de Combate (*Game Feel*) y Ritmo
* **Combate Isométrico Reactivo:** Control instantáneo con cancelación de animaciones mediante el Dash.
* **Frames de Invulnerabilidad (I-Frames):** Esquiva de precisión para evitar hordas y ataques masivos.
* **Telegrafiado Claro (Indicator System):** Áreas rojas luminosas que marcan la zona de impacto de jefes 1.5s antes de golpear.

### C. Bucle Roguelite de Fisuras
* **Incursiones en Brechas Interdimensionales:** En vez de un mapa lineal estático, el jugador entra en fisuras procedurales con modificadores (affixes) aleatorios.
* **Progreso Mixto:** Desbloqueo temporal de runas durante la run + Metaprogreso permanente en la base del Vigilante.

---

## 3. Adaptación Estratégica a *Las Crónicas de Reaper*

### A. De Magia Elemental a "Soul-Crafting" (Forja Rúnica de Almas)
Para encajar en el tono oscuro y la temática del Cosechador de Almas, adaptamos la idea modular al **Sistema de Runas de Almas**:

* **Capa 1: Ejecución (Forma):** Tajo de Guadaña, Barrido 360°, Proyectil Espectral, Grieta del Abismo.
* **Capa 2: Modificador de Alma (Efecto):** Sed de Sangre (Vampirismo), Cenizas de Sombra (DoT), Atracción Abisal (Succión AoE).
* **Capa 3: Desencadenante Rúnico (Trigger):** Activar efecto al cosechar almas, al esquivar con dash o al acertar un golpe crítico.

### B. Visuales y Atmósfera
* **Estilo Artístico:** 2D Top-Down Pintado/Chibi de alto detalle (referencia visual aprobada).
* **Iluminación Dinámica 2D:** Partículas suaves de almas (`GPUParticles2D`), antorchas cálidas y destellos espectrales sobre ruinas oscuras.
