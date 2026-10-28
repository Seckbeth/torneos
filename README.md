# Bracket — gestor de torneos (un solo archivo)

App web para organizar torneos de fighting games con el flujo de Challonge / start.gg:
inscripción por QR, check-in, siembra, pools, doble eliminación, jueces y overlay para OBS.

Todo vive en **`index.html`**. No hay build, no hay backend obligatorio y no hay dependencias
externas (el generador de QR está embebido).

---

## 1. Publicarlo en GitHub Pages

**Ya está publicado:** <https://seckbeth.github.io/torneos/>
(repo: <https://github.com/Seckbeth/torneos>)

GitHub Pages publica desde la rama `gh-pages`, que es una copia de `main`. Para actualizar:

```powershell
.\deploy.ps1                    # usa el mensaje "actualizacion"
.\deploy.ps1 "nuevo overlay"    # o uno propio
```

El script commitea, sube `main` y sincroniza `gh-pages` (que es la que sirve el sitio).
Los cambios tardan ~30 segundos en verse; si no aparecen, recargá con Ctrl+F5.

Desde cero, en otra cuenta:

1. Creá un repositorio **público**, por ejemplo `mi-torneo`.
2. Subí `index.html` a la raíz (arrastrándolo en la web de GitHub alcanza).
3. Creá la rama `gh-pages` con el mismo contenido (o usá
   **Settings → Pages → Deploy from a branch → main / (root) → Save**).
4. En un minuto queda en `https://TU-USUARIO.github.io/mi-torneo/`.

También funciona en Netlify, Cloudflare Pages, Vercel o abriéndolo desde un pendrive:
es un archivo estático.

> El QR necesita que la página esté publicada en una URL (no `file://`), porque lo que
> codifica es el link público del torneo.

---

## 2. Flujo de un torneo

| Paso | Quién | Qué pasa |
|---|---|---|
| Crear torneo | Admin | Nombre, juego, modalidad, formato (doble/simple), BO3/BO5, cupo, jueces y personajes. |
| Inscripción | Jugador | Escanea el QR, pone su nombre y —si el organizador lo habilitó— nick, personaje y nivel. Ve el contador en vivo y queda identificado en ese celular. |
| Check-in | Admin | Marca quién llegó. Los que no están quedan afuera de las llaves. |
| Seeding | Admin | Número de seed manual, siembra automática o aleatoria. |
| Pools | Admin | Si el torneo tiene fase de grupos: *Sortear grupos*, reportar las partidas y *Cerrar grupos y armar bracket*. |
| Iniciar | Admin | El sistema arma el bracket (siempre potencia de 2, con pases directos). |
| Reportar | Admin/Juez | Un click en el ganador o marcador exacto. Se actualiza al instante. |
| Stream | Admin/Juez | Marca una partida "al stream" y el overlay la muestra. |
| En vivo | Jugador | Ve su situación (avanza, espera rival, baja a perdedores, eliminado o campeón), el bracket y su trayectoria. |

**Roles y acceso**

- Al crear el torneo elegís una **contraseña de organizador**. Quedás como admin en ese
  navegador automáticamente; con esa contraseña entrás desde otro celular o PC en
  `#/t/ID/admin`.
- **Solo admin y jueces cargan, editan o borran resultados.** El participante y el público
  solo miran: no tienen botones de reporte.
- En **Jueces** agregás jueces externos o elegís un inscripto. Cada juez recibe su **QR y
  link propio** (`#/t/ID/j/TOKEN`) y un PIN de respaldo. Escanea el QR una vez y queda con
  el panel de gestión en ese celular, igual que el admin: resultados, jugadores, check-in,
  nivel, siembra, stream y pools.
- El juez **no** puede crear otros jueces, cambiar tu contraseña ni reiniciar o rearmar las
  llaves, y no ve la pestaña *Editar*.
- Los jugadores **no** necesitan contraseña ni cuenta: el link de inscripción o el del
  torneo (`#/t/ID`) ya les muestra todo en vivo, sin ninguna opción de organizador.
- En **Jugadores** el admin o un juez puede cambiar el **nivel** de cada jugador con el
  selector de la tabla (—, Principiante, Intermedio, Avanzado), además de nombre, nick,
  personaje, seed y check-in.

**Vista del jugador (celular)**

- Al inscribirse, el celular recuerda quién es (`localStorage`), así que al volver al link
  ve *Tu situación* sin loguearse.
- La tarjeta dice si sigue en carrera, a quién enfrenta, si bajó a perdedores, si quedó
  eliminado o si es campeón. **Mi trayectoria** lista todas sus partidas con marcador.
- Funciona igual si cierra el navegador: al reabrir el link se recalcula desde los
  resultados guardados.

**Formato de llaves**

- Pases directos automáticos cuando el cupo no es potencia de 2 (3, 5, 6, 11 jugadores…).
- Doble eliminación con Winners, Losers y **Grand Final con reset**: si gana el campeón
  de Losers, se juega una segunda final.
- Los resultados se guardan como datos y el bracket se **recalcula** desde cero en cada
  render. Eso permite borrar un resultado viejo y que todo se reacomode solo.

**Fase de grupos (pools estilo EVO)**

- Al crear el torneo elegís cuántos pools (2, 4 u 8) y cuántos pasan por pool (1 o 2).
  Se puede dejar en *Sin fase de grupos* y arrancar directo en eliminación.
- *Sortear grupos* reparte a los jugadores con check-in en serpiente según la siembra
  (1.º y último al mismo pool, etc.), así los cabezas de serie no se cruzan.
- Cada pool es un round robin: todos contra todos, con tabla de posiciones
  (partidas ganadas, diferencia de sets y sets a favor en caso de empate).
- Una vez jugadas todas las partidas, *Cerrar grupos y armar bracket* ordena a los
  clasificados —primeros de cada pool, después los segundos— y arma la eliminación.
  Quedan en el mismo lado del cuadro los ganadores de pools distintos, sin revanchas
  de la fase de grupos en primera ronda.
- Mientras el bracket no tenga resultados, podés volver a Pools y rearmarlo con la
  tabla actual.

**Editar el torneo**

El nombre del evento y el juego quedan fijos al crear. Arriba del resumen está **Editar**:
cambia modalidad, formato (simple/doble), BO3/BO5, opciones del modo por puestos y **qué
datos pedir al inscribirse** (nick, personaje y nivel, además del nombre), incluso con el
torneo en curso. Los links, el QR y las llaves no se tocan. Si cambiás el formato o la
modalidad con partidas jugadas, la app avisa y rearma las llaves desde cero.

**Modo por puestos (Mario Kart, Smash, party games)**

Pensado para juegos donde juegan 3–4 (o más) a la vez y no hay "ganador 1v1":

- Al crear el torneo elegís **Modalidad → Por puestos**, cuántos juegan por partida
  (2 a 8), cuántos pasan a ganadores y cuántos bajan a perdedores.
- Ejemplo típico: **4 por partida, pasan 2 a ganadores, el 3.º baja a perdedores y el
  4.º queda eliminado**.
- Cada partida se reporta **tocando a los jugadores en orden de llegada** (1.º, 2.º, 3.º…).
  Con "ninguno" en perdedores queda como eliminación directa por puestos.
- Los grupos se arman en serpiente por siembra, así los mejores no se cruzan en la
  primera ronda.
- El cuadro de perdedores se arma cuando termina el de ganadores; al final hay una
  **gran final** entre el campeón de ganadores y el de perdedores.
- El bracket muestra el puesto de cada uno y marca **pasa** a los que avanzan.
- En la home, **Ejemplo por puestos** crea uno de 12 jugadores con dos partidas ya
  cargadas (y una pendiente para probar cómo se reporta el orden de llegada).

**Corregir sobre la marcha**

- **Borrar resultado**: en cualquier partida ya jugada (1v1 o por puestos) hay un botón
  para borrarlo y volver atrás; el bracket se recalcula solo.
- **Renombrar jugador**: ✎ en la pestaña Jugadores.
- **Agregar o sacar jugadores** con el torneo empezado: después tocá **Rearmar llaves**
  para reconstruir el cuadro con la lista actual (borra los resultados).
- **Pools**: los resultados de grupos se pueden corregir siempre; si la llave ya estaba
  armada, *Volver a armar el bracket* recalcula los clasificados.

---

## 3. Overlay para OBS

En **Resumen → Overlay OBS** copiás el link. En OBS: *Fuente → Navegador*, 1920×1080,
pegás la URL y listo (fondo transparente).

| URL | Resultado |
|---|---|
| `.../#/t/ID/overlay` | Barra inferior (recomendado, transparente) |
| `.../#/t/ID/overlay?layout=full` | Tarjeta completa a pantalla |
| `.../#/t/ID/overlay?bg=solid` | Fondo opaco, por si el juego no se ve detrás |
| `.../#/t/ID/watch` | Bracket público, sin botones de edición |

La partida que muestra el overlay es la marcada "al stream"; si no hay ninguna, la próxima
pendiente.

---

## 4. Sincronización entre dispositivos (ya configurada)

La copia publicada **ya viene conectada** a una base Supabase gratuita de este proyecto
(proyecto `vrrqrunsgphlkmrxtbcl`): la URL y la clave pública están dentro de `index.html`.
Eso significa que el celular de un jugador, la tablet de un juez y el OBS comparten el
mismo torneo sin configurar nada: abren el link y listo.

Los datos se empujan al guardar y todos los clientes consultan cada ~4 segundos
(incluido el overlay). Es *last write wins*: si dos personas editan lo mismo a la vez,
gana el último guardado.

Para usar **tu propia** base (o si querés cambiar de proyecto):

1. Creá un proyecto en [Supabase](https://supabase.com) y corré este SQL en el *SQL Editor*:

```sql
create table if not exists tournaments (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);
alter table tournaments enable row level security;
create policy "public read"  on tournaments for select using (true);
create policy "public write" on tournaments for insert with check (true);
create policy "public update" on tournaments for update using (true);
```

2. Copiá **Project URL** y la clave **anon / public** desde *Settings → API*.
3. Pegalas en **⚙︎ Ajustes** (queda guardado en ese navegador).
   Para que *todos* los dispositivos las usen sin configurar nada, cambialas en
   `index.html` → `const DEFAULT_CFG = { url: "...", key: "..." }` y volvé a publicar.

> Seguridad: las políticas de arriba son públicas a propósito, para que un celular pueda
> inscribirse sin cuenta. Cualquiera con la URL y la clave pública puede leer/escribir.
> La clave `anon`/`publishable` está pensada para ir en el navegador; no uses la
> `service_role` acá. Para torneos con premio real, conviene cerrar el registro y mover
> la escritura a una función con PIN.
>
> La contraseña de organizador y los links de juez viajan dentro de los datos del torneo,
> que cualquiera con la URL puede leer: sirven para ordenar el acceso entre amigos, no
> como seguridad real.

---

## 5. Detalles útiles

- **Datos**: `localStorage` del navegador. ⚙︎ → *Exportar .json* para respaldar.
- **Ruleta**: lista de personajes editable + *Girar* (animación) o *Asignar a todos*
  (reparte sin repetir hasta agotar la lista).
- **Auto-test del motor**: abrí `#/test` para correr simulaciones de brackets de 4 a 64
  jugadores, con y sin pases directos, verificando campeón, cantidad de derrotas y reset
  de la gran final. También simula torneos **por puestos** (11, 16 y 20 jugadores, 3 a 6
  por partida) y verifica que no haya campeón antes de la gran final.
- **Cupo**: es solo informativo; el tamaño del bracket se calcula al iniciar según los
  jugadores con check-in.

---

## 6. Límites conocidos

- Sin Supabase: un solo navegador (las pestañas del mismo navegador sí se sincronizan).
- Sin cuentas de usuario: el acceso es por contraseña de organizador y link/QR de juez, no hay login real.
- No hay historial de torneos por jugador ni ranking acumulado.
- Agregar o sacar jugadores con el torneo en curso no reacomoda las llaves hasta tocar
  **Rearmar llaves** (se pierden los resultados cargados).
- El bracket se dibuja en columnas con scroll horizontal; no hay vista "full screen"
  autoajustable para 128 jugadores.

Licencia del generador de QR embebido: MIT, (c) 2009 Kazuhiko Arase.
