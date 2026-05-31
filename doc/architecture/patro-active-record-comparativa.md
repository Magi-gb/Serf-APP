# Active Record vs. Row Data Gateway — taula comparativa

Comparació dels dos patrons de Martin Fowler per accedir a dades persistides. Vegeu el
diagrama a [patro-active-record-diagrama.md](patro-active-record-diagrama.md).

| Aspecte | Row Data Gateway | Active Record |
|---|---|---|
| Embolcalla una única fila de la BD | ✅ | ✅ |
| Una instància per fila | ✅ | ✅ |
| Mètodes CRUD (find/insert/update/delete) | ✅ | ✅ |
| Lògica de domini / negoci | ❌ (només accés a dades) | ✅ (validacions, comportament) |

## Resum

- **Row Data Gateway:** capa fina d'accés a dades. Cada objecte representa una fila i només
  s'encarrega de llegir-la i escriure-la. La lògica de domini viu en un objecte separat.
- **Active Record:** afegeix la lògica de negoci de l'entitat dins el mateix objecte que
  gestiona la persistència. És el patró que utilitza Ruby on Rails per als seus models (per
  exemple `User` o `Elaboration`), combinant `save`/`find` amb `validates`, associacions i
  mètodes d'instància.