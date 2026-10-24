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
| Crear torneo | Admin | Nombre, juego, formato (doble/simple), BO3/BO5, cupo y personajes. |
| Inscripción | Jugador | Escanea el QR, pone nombre y personaje. Ve el contador en vivo. |
| Check-in | Admin/Juez | Marca quién llegó. Los que no están quedan afuera de las llaves. |
| Seeding | Admin | Número de seed manual, siembra automática o aleatoria. |
| Pools | Admin | Si el torneo tiene fase de grupos: *Sortear grupos*, reportar las partidas y *Cerrar grupos y armar bracket*. |
| Iniciar | Admin | El sistema arma el bracket (siempre potencia de 2, con pases directos). |
| Reportar | Admin/Juez | Un click en el ganador o marcador exacto. Se actualiza al instante. |
| Stream | Admin/Juez | Marca una partida "al stream" y el overlay la muestra. |

**Roles y PIN**

- El creador queda como admin en ese navegador automáticamente.
- En **Jueces** está el PIN de admin (para entrar desde otro dispositivo) y se crean
  jueces con su propio PIN.
- El juez solo ve Resumen, Jugadores (check-in) y Bracket. No puede borrar resultados,
  reiniciar llaves ni tocar la siembra.

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

Arriba del resumen está **Editar**: cambia nombre del evento, juego y BO3/BO5 en
cualquier momento, incluso con el torneo en curso. Los links, el QR y las llaves no
se tocan.

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

## 4. Sincronización entre dispositivos (opcional)

Sin configurar nada, la app es **local**: un solo navegador. Sirve para organizar desde la
laptop del TO y proyectar el bracket, pero el celular de un juez o el OBS no ven los cambios.

Para que varios dispositivos compartan el mismo torneo, creá un proyecto gratis en
[Supabase](https://supabase.com), corré este SQL en el editor y pegá URL + anon key en **⚙︎ Ajustes**:

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

El panel empuja los cambios y todos los clientes consultan cada ~3 segundos (incluido el
overlay). Es *last write wins*: si dos personas editan el mismo torneo al mismo tiempo,
gana el último guardado.

> Seguridad: las políticas de arriba son públicas a propósito, para que un celular pueda
> inscribirse sin cuenta. Cualquiera con la URL y la anon key puede leer/escribir. Para
> torneos con premio real, conviene cerrar el registro y mover la escritura a una función
> con PIN.

---

## 5. Detalles útiles

- **Datos**: `localStorage` del navegador. ⚙︎ → *Exportar .json* para respaldar.
- **Ruleta**: lista de personajes editable + *Girar* (animación) o *Asignar a todos*
  (reparte sin repetir hasta agotar la lista).
- **Auto-test del motor**: abrí `#/test` para correr simulaciones de brackets de 4 a 64
  jugadores, con y sin pases directos, verificando campeón, cantidad de derrotas y reset
  de la gran final.
- **Cupo**: es solo informativo; el tamaño del bracket se calcula al iniciar según los
  jugadores con check-in.

---

## 6. Límites conocidos

- Sin Supabase: un solo navegador (las pestañas del mismo navegador sí se sincronizan).
- Sin cuentas de usuario: el acceso es por PIN, no hay login real.
- No hay historial de torneos por jugador ni ranking acumulado.
- El bracket se dibuja en columnas con scroll horizontal; no hay vista "full screen"
  autoajustable para 128 jugadores.

Licencia del generador de QR embebido: MIT, (c) 2009 Kazuhiko Arase.
