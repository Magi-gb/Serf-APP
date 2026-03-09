import { kv } from '@vercel/kv';

export default async function handler(req, res) {
    // CORS Basics para preflights
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // Responder a preflight requests HTTP en fetch API si el dominio varía
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    // Comprobar estrictamente el POST
    if (req.method !== 'POST') {
        return res.status(405).json({ ok: false, error: 'Método no permitido.' });
    }

    try {
        const { email } = req.body;

        // Validación Backend idéntica al front
        if (!email || typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            return res.status(400).json({ ok: false, error: 'Has introducido un formato de correo electrónico inválido.' });
        }

        const cleanEmail = email.trim().toLowerCase();

        // Vercel KV: Guardar en un "Set" (`sadd`) permite deduplicación automática de emails.
        // Si ya existe dentro de la key 'serf:subscribers', Upstash lo ignora silenciosamente devolviendo 0.
        await kv.sadd('serf:subscribers', cleanEmail);

        // Responder siempre de manera educada para evitar list leaks al usuario malicioso.
        return res.status(200).json({ ok: true, message: '¡Te has unido con éxito!' });

    } catch (error) {
        console.error('SERVERLESS ERROR SERF-KV:', error);

        // Manejo de caótica base de datos / Vercel KV mal configurado enviando un log
        return res.status(500).json({
            ok: false,
            error: 'Problema en los servidores. Por favor inténtalo más tarde.'
        });
    }
}
