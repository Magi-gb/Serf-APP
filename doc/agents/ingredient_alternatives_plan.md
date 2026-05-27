# Alternatives d'ingredients

Aquest document descriu com gestionar alternatives (substituts) per a un ingredient.

## Objectiu

Permetre que el **responsable de cuina** (i l'admin) defineixin ingredients alternatius que **no introdueixin noves restriccions** respecte l'ingredient original. Això permet substituir ingredients problemàtics (al·lèrgens/intoleràncies, restriccions religioses, etc.) per opcions més segures.

## Permisos

- **kitchen_manager / admin**: poden afegir i eliminar alternatives.
- **waiter**: només pot consultar-les (no pot modificar-les).

## Com afegir una alternativa (UI)

1. Ves a **Ingredients**.
2. Obre el detall d'un ingredient.
3. A la secció **"Afegir alternativa"**, selecciona un ingredient del desplegable.
4. Prem **"Afegir alternativa"**.

### Regles de validació

- No es pot afegir un ingredient com a alternativa de si mateix.
- Una alternativa **no pot afegir restriccions noves** respecte l'ingredient original.
  - Exemple: si l'ingredient original té `Gluten`, una alternativa pot tenir `[]` (cap) o `[Gluten]`,
    però **no** pot afegir `Kosher` si l'original no el té.

## Com veure les alternatives

Al detall de l'ingredient, hi ha una secció **"Alternatives"** on es mostren totes les alternatives associades.

## Endpoints

Les alternatives es gestionen com a recurs anidat sota ingredients:

- Crear alternativa:
  - `POST /ingredients/:ingredient_id/alternatives`
- Eliminar alternativa:
  - `DELETE /ingredients/:ingredient_id/alternatives/:id`
  - on `:id` és l'**ID de l'ingredient alternatiu**.
