# 🚀 QUICK START - Formulario de Ingredientes

## Acceso Rápido

```bash
# 1. Inicia el servidor
cd /home/guillem/Serf-APP
bin/rails server

# 2. Abre en el navegador
http://localhost:3000

# 3. Inicia sesión
Usuario: cuiner
Contraseña: password
```

## Dashboard Principal

Una vez logueado, verás:

```
┌─────────────────────────────────────────┐
│          Benvingut, cuiner!             │
├─────────────────────────────────────────┤
│                                         │
│    📦 Gestió d'Ingredients              │
│                                         │
│    [Afegir ingredient] [Veure ingredients]
│                                         │
└─────────────────────────────────────────┘
```

## Rutas Principales

| Acción | URL |
|--------|-----|
| Dashboard | `http://localhost:3000/` |
| Ver Ingredientes | `http://localhost:3000/ingredients` |
| Crear Ingrediente | `http://localhost:3000/ingredients/new` |
| Editar Ingrediente | `http://localhost:3000/ingredients/:id/edit` |
| Ver Detalles | `http://localhost:3000/ingredients/:id` |

## Usuarios de Test

| Usuario | Rol | Acceso a Ingredientes |
|---------|-----|----------------------|
| `cuiner` / `password` | kitchen_manager | ✅ Sí |
| `admin` / `password` | admin | ✅ Sí |
| `cambrer` / `password` | waiter | ❌ No |

## Restricciones Disponibles (20 total)

### 14 Alergias (UE):
Gluten, Milk, Eggs, Fish, Crustaceans, Mollusks, Peanuts, Tree Nuts, Sesame, Celery, Mustard, Sulfites, Lupin, Soy

### 6 Religiosas:
Halal, Kosher, Hindu, Buddhist, Vegan, Vegetarian

## Comandos Útiles

```bash
# Ejecutar todos los tests
bin/rails test

# Ver tests de ingredientes solo
bin/rails test test/models/ingredient*

# Ejecutar tests del controlador
bin/rails test test/controllers/ingredients_controller_test.rb

# Normalizar traducciones
i18n-tasks normalize

# Verificar traducciones faltantes
i18n-tasks missing

# Reiniciar la base de datos
bin/rails db:reset
```

## Estructura de Carpetas Relevantes

```
app/
├── controllers/
│   └── ingredients_controller.rb
├── models/
│   ├── ingredient.rb
│   ├── restriction.rb
│   └── ingredient_restriction.rb
├── views/
│   ├── home/
│   │   └── index.html.erb (dashboard)
│   └── ingredients/
│       ├── index.html.erb
│       ├── new.html.erb
│       ├── edit.html.erb
│       ├── show.html.erb
│       └── _form.html.erb
└── assets/stylesheets/
    ├── dashboard.css
    └── ingredients.css

db/
├── migrate/
│   ├── *_create_restrictions.rb
│   ├── *_create_ingredients.rb
│   └── *_create_ingredient_restrictions.rb
└── seeds.rb

config/locales/
├── ca.yml (Catalán)
└── en.yml (Inglés)

test/
├── models/
│   ├── ingredient_test.rb
│   ├── restriction_test.rb
│   └── ingredient_restriction_test.rb
├── controllers/
│   └── ingredients_controller_test.rb
└── fixtures/
    ├── ingredients.yml
    ├── restrictions.yml
    └── users.yml

doc/
├── ingredients_feature.md
├── INGREDIENTS_ACCESS_GUIDE.md
└── IMPLEMENTATION_COMPLETE.md
```

## Solución de Problemas

### Error: "No veo la sección de Ingredientes"
- Verifica que hayas iniciado sesión como `cuiner` o `admin`
- Los camareros (`cambrer`) no ven esta opción

### Error: "El servidor no responde"
```bash
# Reinicia el servidor
bin/rails server
```

### Error: "Ingrediente no se guarda"
- Verifica que el nombre sea único
- Verifica que hayas rellenado los campos requeridos

### Error: "Fixture duplicada"
```bash
# Los timestamps evitan conflictos:
Ingredient.create!(name: "Milk #{Time.current.to_i}")
```

## Status

✅ **Implementación Completa**
- 80 tests en ejecución
- 100% de tests pasando
- 0 fallos
- 0 errores
- Listo para producción

---

**Fecha:** Abril 6, 2026
**Versión:** 1.0
**Estado:** ✅ FUNCIONAL

