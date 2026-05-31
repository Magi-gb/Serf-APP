# Estratègia de proves — Motor de suggeriments (`SuggestionService`)

Aquest document descriu com s'ha testejat la funcionalitat de suggeriment de
plats alternatius (`SuggestionService#alternatives`), pensat per a l'informe de
final d'iteració.

- **Codi sota prova:** `app/services/suggestion_service.rb`
- **Proves:** `test/services/suggestion_service_test.rb` (8 tests, 22 assercions)
- **Tasca Taiga:** #207

---

## 1. Què fa la funcionalitat

`SuggestionService.new(plat).alternatives(restriccions_a_excloure)` retorna fins a
**5** plats alternatius a un plat donat. La lògica té dues etapes ben diferenciades,
i aquesta separació és la que determina quina metodologia de prova s'aplica a cada part:

1. **Filtratge** — un plat candidat és compatible si compleix *totes* aquestes condicions:
   - és del mateix tipus (`dish_type`) que el plat base,
   - no és el plat base mateix,
   - cap dels seus ingredients porta una restricció exclosa, ni **directament** ni
     **a través d'una elaboració**.
2. **Selecció** — els compatibles s'ordenen pel nombre d'ingredients compartits amb
   el plat base (descendent) i se'n retornen els **5 primers** (`first(5)`).

---

## 2. Metodologies aplicades i per què

S'han combinat **dues** tècniques de caixa negra, cadascuna a la part on aporta més valor:

| Part de la lògica | Metodologia | Motiu |
|---|---|---|
| Filtratge (etapa 1) | **Particions per classes d'equivalència** | El comportament està dominat per dimensions d'entrada independents (tipus, identitat, presència de restricció, via per la qual la porta). N'hi ha prou amb un representant de cada classe. |
| Cap de resultats (etapa 2) | **Anàlisi de valors frontera** | El `first(5)` és una frontera numèrica explícita al 5: cal provar just per sota, just al límit i just per sobre. |

**Per què no taules de decisió:** les tres condicions del filtratge s'enllacen amb un
AND simple (si una falla, el candidat queda fora) i no interactuen entre elles. Una
taula de decisió de 2³ = 8 regles col·lapsaria a una sola regla útil, així que no
aporta cobertura addicional respecte de les classes d'equivalència.

---

## 3. Casos de prova

### 3.1 Filtratge — classes d'equivalència

| Test | Classe d'entrada coberta | Resultat esperat |
|---|---|---|
| `only returns dishes of the same type and never the dish itself` | tipus {igual / diferent} · identitat {ell mateix / un altre} | inclou el mateix tipus; exclou un altre tipus i el plat base |
| `excludes dishes carrying any excluded restriction through a direct ingredient` | restricció via **ingredient directe** {present / absent} | exclou el plat amb la restricció; inclou el segur (encara que comparteixi més ingredients) |
| `excludes candidates carrying an excluded restriction through an elaboration` | restricció via **elaboració** {present / absent} | exclou el plat que porta la restricció via elaboració; inclou el que té una elaboració sense restriccions |

> El darrer test cobreix la branca `elaborations.flat_map(&:ingredients)` del servei,
> que abans no tenia cobertura. Es prova la via d'elaboració en els **dos sentits**
> (exclou quan hi ha restricció, manté quan no n'hi ha) per assegurar que el
> recorregut d'elaboracions no exclou de més.

### 3.2 Ordenació (rànquing)

| Test | Què comprova |
|---|---|
| `ranks candidates by number of shared ingredients, descending` | amb candidats que comparteixen 3, 2 i 1 ingredients, l'ordre del resultat és exactament \[3, 2, 1] |
| `keeps tied candidates together, ahead of less similar dishes` | dos candidats empatats (comparteixen 2) van tots dos al davant d'un de menys similar (comparteix 1). Com que `sort_by` **no és estable**, no s'afirma cap ordre *entre* els empatats; només que tots dos superen el menys similar |

### 3.3 Cap de resultats — valors frontera (frontera = 5)

| Test | Nre. de candidats | Resultat esperat | Posició respecte la frontera |
|---|---|---|---|
| `returns every candidate when fewer than five exist` | 4 | 4 | just per sota |
| `returns exactly five when exactly five candidates exist` | 5 | 5 | al límit |
| `caps the result at five when more than five candidates exist` | 6 | 5 | just per sobre |

> Aquests tests buiden primer els plats del tipus escollit (`clear_dishes`) perquè
> els plats de les *fixtures* no inflin el recompte de candidats; així el nombre de
> candidats compatibles queda controlat de manera exacta.

---

## 4. Tècnica de muntatge de dades

Les *fixtures* són massa escasses per exercitar el rànquing, de manera que els tests
construeixen els seus propis ingredients i plats mitjançant ajudants privats:

- `dish_with(type, ingredients, elaborations:)` — crea un plat amb els ingredients i
  elaboracions indicats.
- `clear_dishes(type)` — elimina els plats existents d'un tipus per controlar el
  recompte exacte de candidats als tests de frontera.

Com que els ingredients creats són nous, els plats de les *fixtures* comparteixen 0
ingredients amb el plat base i sempre queden per sota de qualsevol candidat construït.

---

## 5. Resultat

```
8 runs, 22 assertions, 0 failures, 0 errors, 0 skips
```

Sense ofenses de RuboCop. La cobertura inclou les dues vies del filtratge
(ingredient directe i elaboració), l'ordenació amb empats i les tres fronteres del
cap de 5 resultats.
