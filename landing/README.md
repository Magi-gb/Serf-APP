# SERF Landing Page

Landing page creada para promocionar **SERF**, con un diseño elegante mobile-first, animaciones ASCII programadas, carrusel y API Serverless.

## Características técnicas y stack
- **HTML5, CSS3, ES6 Vanilla** sin dependencias front-end.
- **Fondo animado ASCII (`<canvas>`)** con rendimiento de 30FPS auto-limitado, responsivo y conectado a `prefers-reduced-motion` a favor de la accesibilidad.
- **Carrusel JS nativo** (soporta swiping responsivo, scroll horizontal directo e incluye pausas on-touch o al pasar el ratón).
- **Endpoint Vercel Serverless (`/api/subscribe.js`)** con persistencia Upstash (Vercel KV Database) y deduplicación en memoria garantizada.

## Estructura de Proyecto

```text
/SERF-landing
├── /assets/             
│    ├── logo.png           <-- ¡Colocar archivo .png real aquí!
│    └── app-home.png       <-- ¡Colocar mockup real aquí!
├── /api/                
│    └── subscribe.js       <-- Función serverless Node con @vercel/kv
├── index.html           
├── styles.css           
├── script.js            
└── package.json         <-- Vercel lo detectará para instalar el SDK backend
```

## Instrucciones y despliegue

Al estar preparado para **Vercel**, el proceso de encendido es automático:

### 1) Sube este código a GitHub o súbelo por Vercel CLI
Simplemente crea un proyecto nuevo, enlázalo. Como el preset base es estático, lo detectará correctamente y habilitará la tab de API Functions (`/api`).

### 2) Base de datos (Storage de Correos - KV)
Sigue religiosamente estos pasos en el dashboard del proyecto:
1. Navega a tu proyecto den Vercel en la configuración → **Storage**.
2. Presiona sobre **Create Database** e inicializa un **Vercel KV** (Redis).
3. Acéptalo y dáselo al proyecto actual.
4. Magia: las variables globales de autorización (`KV_URL`, `KV_REST_API_URL`, etc) se mapean instantaneamente en este entorno, tu `/api/subscribe.js` empezará a trabajar al momento.

Para validar quién se inscribe, abre el Data Explorer del Vercel KV en el Dashboard y mira el valor Set llamado `serf:subscribers`.

### 3) Assets
Modifica localmente o en el repo las imágenes asegurando el mismo formato y tamaño prudencial (`app-home.png` y `logo.png`).

---
_Cero dependencias pesadas. 100% elegancia._
