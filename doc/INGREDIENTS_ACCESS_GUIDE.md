# Guía de Acceso - Formulario de Ingredientes

## 🚀 Inicio Rápido

### 1. **Inicia el servidor** (si no está corriendo)
```bash
cd /home/guillem/Serf-APP
bin/rails server
```

### 2. **Accede a la aplicación**
- Abre tu navegador y ve a: `http://localhost:3000`

### 3. **Inicia sesión como "cuiner"**
```
Usuario: cuiner
Contraseña: password
```

---

## 📋 Dashboard Principal

Una vez iniciado sesión, verás el dashboard personalizado:

```
┌─────────────────────────────────────┐
│           Serf                      │
│      Benvingut, cuiner!             │
└─────────────────────────────────────┘

┌──────────────────────────────────────────┐
│    Gestió d'Ingredients                  │
│                                          │
│  Crea i gestiona els ingredients del     │
│  restaurant amb les seves restriccions   │
│  alimentàries.                           │
│                                          │
│  [Afegir ingredient] [Veure ingredients] │
└──────────────────────────────────────────┘
```

---

## ✨ Opciones Disponibles por Rol

### 👨‍🍳 **Responsable de Cuina (cuiner)**
- ✅ Crear nuevos ingredientes
- ✅ Ver lista de ingredientes
- ✅ Editar ingredientes existentes
- ✅ Eliminar ingredientes
- ❌ Gestionar usuarios

### 🔐 **Administrador (admin)**
- ✅ Crear nuevos ingredientes (igual que cuiner)
- ✅ Ver lista de ingredientes (igual que cuiner)
- ✅ Editar ingredientes existentes (igual que cuiner)
- ✅ Eliminar ingredientes (igual que cuiner)
- ✅ **Gestionar usuarios (adicional)**

### 🚫 **Camarero (cambrer)**
- ❌ No tiene acceso al formulario de ingredientes
- ❌ No ve la sección "Gestió d'Ingredients"
- Verá solo "Funcionalitats del Cambrer" (próximamente)

---

## 🎯 Crear un Ingrediente

### Paso 1: Haz clic en "Afegir ingredient"
Desde el dashboard principal

### Paso 2: Completa el formulario
```
┌─────────────────────────────────────┐
│   Nou ingredient                    │
│                                     │
│   Nom: [Leche                      │
│   Descripció: [Leche de vaca...]   │
│                                     │
│   ☑ Intoleràncies i al·lèrgies     │
│   ☑ Milk                           │
│   ☐ Fish                           │
│   ☑ Restriccions religioses        │
│   ☑ Halal                          │
│                                     │
│            [Crear ingredient]       │
└─────────────────────────────────────┘
```

### Paso 3: Selecciona restricciones
- Las restricciones están organizadas en 2 categorías:
  1. **Intolerancias y Alergias (14 de la UE)**
  2. **Restricciones Religiosas**

### Paso 4: Envía el formulario
Haz clic en "Crear ingredient"

---

## 📁 Ver Ingredientes

### Opción 1: Desde el Dashboard
- Haz clic en "Veure ingredients"

### Opción 2: Acceso directo
- Navega a: `http://localhost:3000/ingredients`

### Funcionalidades de la Lista
- **Búsqueda:** Campo superior para buscar por nombre
- **Tarjetas:** Cada ingrediente se muestra como una tarjeta
- **Badges:** Muestran los tipos de restricciones
  - 🟡 Amarillo/Naranja: Intolerancias y alergias
  - 🔵 Azul/Verde: Restricciones religiosas

---

## ✏️ Editar un Ingrediente

### Paso 1: Haz clic en una tarjeta de ingrediente
De la lista de ingredientes

### Paso 2: Haz clic en "Editar dades"
En la página de detalles

### Paso 3: Actualiza los datos
- Puedes cambiar nombre, descripción y restricciones

### Paso 4: Haz clic en "Desar canvis"
Para guardar los cambios

---

## 🗑️ Eliminar un Ingrediente

### Paso 1: Haz clic en una tarjeta de ingrediente
De la lista de ingredientes

### Paso 2: Haz clic en "Eliminar"
En la página de detalles

### Paso 3: Confirma la acción
Se pedirá confirmación antes de eliminar

---

## 🔒 Restricciones de Seguridad

✅ **Solo usuarios autenticados** pueden acceder a la aplicación
✅ **Solo kitchen_manager y admin** pueden ver/crear/editar ingredientes
✅ **CSRF Protection** habilitado en todos los formularios
✅ **Strong Parameters** en el controlador

---

## 📞 Resolución de Problemas

### "No veo la sección 'Gestió d'Ingredients'"
- Verifica que hayas iniciado sesión como "cuiner" o "admin"
- Los camareros no ven esta opción

### "El servidor no responde"
```bash
# Reinicia el servidor
cd /home/guillem/Serf-APP
bin/rails server
```

### "No puedo editar un ingrediente"
- Verifica que tengas permisos (debes ser kitchen_manager o admin)
- Comprueba que el ingrediente existe

---

## 📊 Restricciones Disponibles

### 14 Alergias de la Unión Europea:
1. Gluten (Cereals)
2. Milk
3. Eggs
4. Fish
5. Crustaceans
6. Mollusks
7. Peanuts
8. Tree Nuts
9. Sesame
10. Celery
11. Mustard
12. Sulfites
13. Lupin
14. Soy

### 6 Restricciones Religiosas:
1. Halal
2. Kosher
3. Hindu
4. Buddhist
5. Vegan
6. Vegetarian

---

**¡Disfruta gestionando los ingredientes del restaurant!** 🍽️

