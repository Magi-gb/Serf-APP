# CRUD45 — Revisión de código (Restrictions)

## BUG-1 — Falta control de acceso (CRITICAL)

No se ha implementado control de acceso en `RestrictionsController`. Solo los responsables de cocina (y administradores) deberían poder gestionar restricciones (acciones `create`, `update`, `delete`, `edit`, `new`). Además, hay que evaluar si tiene sentido que los camareros tengan acceso a las acciones de visualización (`index` y `show`).

**Acción requerida:** Aplicar los mecanismos de control de acceso del módulo `Authorizable` (`require_admin!`, `require_kitchen_manager_or_above!`, etc.).

## BUG-2 — Literales sin internacionalización (CRITICAL)

El controlador `RestrictionsController` inyecta literales en inglés directamente en los mensajes flash (`notice`). La aplicación está en catalán y todos los textos visibles al usuario deben pasar por el sistema de internacionalización I18n (es decir, definir los textos en `config/locales/*.yml` y obtenerlos con `I18n.t`).

Además, algunos cambios de esta rama han sustituido código que ya usaba I18n correctamente por literales directos. Hay que revertir esos cambios y reutilizar las claves de traducción existentes en `develop` — no duplicar traducciones.

Ficheros afectados:
* `app/controllers/restrictions_controller.rb` — mensajes flash en inglés (`"Restriction was successfully created."`, etc.)
* `app/views/layouts/_sidebar.html.erb` — textos de enlaces (`"Menú"`, `"Glossari"`, `"Protocols"`, `"Emergències"`, `"Tancar sessió"`, etc.)
* `app/views/restrictions/_form.html.erb` — labels y textos (`"Nom de la restricció"`, `"Descripció detallada"`, `"Guardar restricció"`, `"Cancel·lar"`, placeholder)
* `app/views/restrictions/_restriction.html.erb` — etiquetas en inglés (`"Name:"`, `"Description:"`, `"Bg color:"`)
* `app/views/restrictions/edit.html.erb` — título `"Editar Restricció"`
* `app/views/restrictions/index.html.erb` — título `"Restriccions"`, texto vacío `"Encara no hi ha restriccions guardades."`, `content_for :title`
* `app/views/restrictions/new.html.erb` — título `"Crear Nova Restricció"`
* `app/views/restrictions/show.html.erb` — textos de botones (`"Eliminar Restricció"`, `"Editar"`, `"Tornar"`), encabezado `"Descripció de la restricció"`, fallback `"Sense descripció addicional."`, `turbo_confirm`

**Acción requerida:** Eliminar todos los literales directos y sustituirlos por claves I18n con traducción al catalán. Reutilizar las claves ya existentes en `develop`.

## BUG-3 — Modelo sin validaciones (HIGH)

El modelo `Restriction` no tiene ninguna validación, lo que permite crear restricciones duplicadas, sin nombre o sin descripción.

**Acción requerida:** Añadir validaciones de presencia y unicidad como mínimo.

## FLAW-1 — Código muerto en el controlador (HIGH)

`RestrictionsController` gestiona múltiples formatos de respuesta (`respond_to` con `format.html` y `format.json`). El desarrollo de una API está fuera del alcance de este proyecto, por lo que el manejo del formato JSON es código muerto que complica el controlador innecesariamente.

**Acción requerida:** Simplificar el controlador eliminando los bloques `respond_to` y dejando solo el flujo HTML.

Ejemplo de simplificación:
```diff
diff --git a/app/controllers/restrictions_controller.rb b/app/controllers/restrictions_controller.rb
index fc106f3..dd066f8 100644
--- a/app/controllers/restrictions_controller.rb
+++ b/app/controllers/restrictions_controller.rb
@@ -23,14 +23,10 @@ class RestrictionsController < ApplicationController
   def create
     @restriction = Restriction.new(restriction_params)
 
-    respond_to do |format|
-      if @restriction.save
-        format.html { redirect_to @restriction, notice: "Restriction was successfully created." }
-        format.json { render :show, status: :created, location: @restriction }
-      else
-        format.html { render :new, status: :unprocessable_entity }
-        format.json { render json: @restriction.errors, status: :unprocessable_entity }
-      end
+    if @restriction.save
+      redirect_to @restriction, notice: "Restriction was successfully created."
+    else
+      render :new, status: :unprocessable_entity
     end
   end
```

## FLAW-2 — Icono almacenado como binario en la base de datos (LOW)

El modelo `Restriction` almacena el binario del icono directamente en la base de datos como campo `TEXT`. Aunque en un proyecto pequeño esto no es crítico, es un antipatrón: los archivos subidos deberían guardarse en el sistema de ficheros y en la base de datos solo se debería almacenar la ruta. Una alternativa idiomática en Rails sería usar ActiveStorage.

**Acción requerida:** Valorar migración a ActiveStorage o almacenamiento en disco.

## FLAW-3 — Estilos inline en las vistas (MEDIUM)

Se han introducido atributos `style` directamente en el HTML de varias vistas. Los estilos deben aplicarse mediante clases CSS definidas en los ficheros de estilos correspondientes.

Ficheros afectados:
* `app/views/layouts/_sidebar.html.erb` — logo (`width`, `filter`), botón de cerrar sesión (`background`, `border`, `padding`, etc.), contenedor (`padding`, `margin-bottom`)
* `app/views/restrictions/_form.html.erb` — enlace cancelar (`background-color`, `color`), contenedor de errores (`color`, `margin-bottom`, `padding`, `background-color`, `border-radius`), lista de errores (`margin-bottom`), botones (`display`, `gap`, `margin-top`)
* `app/views/restrictions/edit.html.erb` — título (`color`, `margin`), contenedor (`display`, `gap`, `align-items`, `width`), icono (`background-color`, `margin`, `width`, `height`, `font-size`)
* `app/views/restrictions/index.html.erb` — título (`color`, `flex`), contenedor (`background-color`, `box-shadow`, `padding`), mensaje vacío (`text-align`, `color`, `padding`), iconos (`background-color`)
* `app/views/restrictions/new.html.erb` — título (`color`, `margin-bottom`)
* `app/views/restrictions/show.html.erb` — enlace editar (`text-decoration`), enlace tornar (`background-color`, `color`), bloque descripción (`background-color`, `padding`, `border-radius`, `margin-bottom`), encabezado (`margin-top`, `color`), párrafo (`color`, `line-height`, `font-size`), contenedor botones (`display`, `gap`)

**Acción requerida:** Eliminar todos los atributos `style` y sustituirlos por clases CSS.

## FLAW-4 — Sidebar muestra enlaces sin comprobar permisos (MEDIUM)

El sidebar muestra todos los enlaces de navegación independientemente del rol del usuario. Debería mostrar solo los elementos a los que el usuario actual tiene acceso.

**Acción requerida:** Condicionar la visibilidad de los enlaces del sidebar según el rol del usuario.

## FLAW-5 — Partial sin uso (HIGH)

El fichero `app/views/restrictions/_restriction.html.erb` no se utiliza en ninguna parte.

**Acción requerida:** Eliminar el fichero si no es necesario.

## FLAW-6 — Ficheros jbuilder innecesarios (HIGH)

Los ficheros `.jbuilder` generados por el scaffold son innecesarios: no se desarrolla una API y además el controlador no los usa (hace `render json` inline).

**Acción requerida:** Eliminar todos los ficheros `app/views/restrictions/**/*.jbuilder`.

## FLAW-7 — Test de sistema fuera de convención (LOW)

Existe un fichero `spec/system/restrictions_test.rb`, pero en este proyecto no se usan tests de sistema.

**Acción requerida:** Eliminar el fichero.

---

## Resumen

| Prioridad | ID | Título | Acción |
|-----------|---|---|---|
| CRITICAL  | BUG-1 | Falta control de acceso | Aplicar `Authorizable` en el controlador |
| CRITICAL  | BUG-2 | Literales sin I18n | Sustituir todos los literales por claves I18n |
| HIGH      | BUG-3 | Modelo sin validaciones | Añadir validaciones de presencia y unicidad |
| HIGH      | FLAW-1 | Código muerto (JSON) | Eliminar bloques `respond_to` del controlador |
| HIGH      | FLAW-5 | Partial sin uso | Eliminar `_restriction.html.erb` |
| HIGH      | FLAW-6 | Ficheros jbuilder innecesarios | Eliminar ficheros `.jbuilder` |
| MEDIUM    | FLAW-4 | Sidebar sin control de permisos | Condicionar enlaces según rol |
| MEDIUM    | FLAW-3 | Estilos inline | Mover estilos a clases CSS |
| LOW       | FLAW-2 | Icono como binario en BD | Valorar migración a ActiveStorage |
| LOW       | FLAW-7 | Test de sistema fuera de convención | Eliminar fichero de test |
