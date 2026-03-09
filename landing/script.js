document.addEventListener('DOMContentLoaded', () => {

    // ======================================
    // 0. IDIOMAS (i18n)
    // ======================================
    if (window.setLang) {
        window.setLang('ca'); // Init to Catalan text by default (even though text in html is already CA, this updates active class and stores states)
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                window.setLang(btn.getAttribute('data-lang'));
            });
        });
    }

    // ======================================
    // 1. ANTES DE NADA: ASCII BACKGROUND
    // ======================================
    const canvas = document.getElementById('ascii-bg');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        const fontSize = 16;
        const chars = " ·-~:+=*#%@"; // Density characters for wave effect

        let w, h, cols, rows;
        let timeObj = 0;

        const resize = () => {
            w = window.innerWidth;
            h = window.innerHeight;
            canvas.width = w * window.devicePixelRatio;
            canvas.height = h * window.devicePixelRatio;
            ctx.scale(window.devicePixelRatio, window.devicePixelRatio);

            cols = Math.ceil(w / fontSize) + 1;
            rows = Math.ceil(h / fontSize) + 1;
        };

        window.addEventListener('resize', resize);
        resize();

        const renderASCII = () => {
            // Background is transparent to show page bg underneath, just draw darker ASCII
            ctx.clearRect(0, 0, w, h);
            ctx.fillStyle = '#e0e0d3'; // Un crema oscuro para que destaque claramente el patrón animado
            ctx.font = `${fontSize}px "ui-monospace", "SFMono-Regular", Menlo, Monaco, Consolas, monospace`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';

            const driftX = Math.sin(timeObj * 0.5) * 5;
            const driftY = Math.cos(timeObj * 0.3) * 5;

            // Draw flowing wavy noise
            for (let y = 0; y < rows; y++) {
                for (let x = 0; x < cols; x++) {
                    const px = x * fontSize + fontSize / 2;
                    const py = y * fontSize + fontSize / 2;

                    const nx = (x + driftX * 0.5) * 0.05;
                    const ny = (y + driftY * 0.5) * 0.05;

                    const wave1 = Math.sin(nx * 1.5 + timeObj);
                    const wave2 = Math.cos(ny * 2.0 - timeObj * 1.2);
                    const wave3 = Math.sin((nx + ny) * 1.0 + timeObj * 1.5);

                    const noise = (wave1 + wave2 + wave3) / 3;

                    const normalized = Math.max(0, Math.min(1, (noise + 1) / 2));
                    const charIndex = Math.floor(normalized * (chars.length - 1));

                    ctx.fillText(chars[charIndex], px, py);
                }
            }

            timeObj += 0.035; // Constantly updates time for random wavy motion
            requestAnimationFrame(renderASCII);
        };

        requestAnimationFrame(renderASCII);
    }

    // ======================================
    // 2. CARRUSEL JS
    // ======================================
    const track = document.getElementById('carousel-track');
    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');

    if (track && prevBtn && nextBtn) {
        // Obtenemos ancho aproximado de una tarjeta + padding
        const getScrollAmount = () => track.offsetWidth < 768 ? track.offsetWidth * 0.85 : 340;

        prevBtn.addEventListener('click', () => {
            track.scrollBy({ left: -getScrollAmount(), behavior: 'smooth' });
        });

        nextBtn.addEventListener('click', () => {
            track.scrollBy({ left: getScrollAmount(), behavior: 'smooth' });
        });

        // Autoplay
        let autoPlayInterval;
        const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

        const startAutoplay = () => {
            if (reducedMotion) return;
            autoPlayInterval = setInterval(() => {
                // Si llegamos casi al final, loop
                if (track.scrollLeft + track.clientWidth >= track.scrollWidth - 20) {
                    track.scrollTo({ left: 0, behavior: 'smooth' });
                } else {
                    track.scrollBy({ left: getScrollAmount(), behavior: 'smooth' });
                }
            }, 5000);
        };

        const stopAutoplay = () => clearInterval(autoPlayInterval);

        startAutoplay();
        // Hover/touch events manejan el auto slider con easing natural
        track.addEventListener('mouseenter', stopAutoplay);
        track.addEventListener('mouseleave', startAutoplay);
        track.addEventListener('touchstart', stopAutoplay, { passive: true });
    }

    // ======================================
    // 3. ACORDEÓN (FAQ)
    // ======================================
    const accordionTriggers = document.querySelectorAll('.accordion-trigger');

    accordionTriggers.forEach(trigger => {
        trigger.addEventListener('click', () => {
            const isExpanded = trigger.getAttribute('aria-expanded') === 'true';
            const controls = trigger.getAttribute('aria-controls');
            const content = document.getElementById(controls);

            // Cerrar el resto para experiencia limpia (acordeón estricto)
            accordionTriggers.forEach(t => {
                if (t !== trigger) {
                    t.setAttribute('aria-expanded', 'false');
                    const tContent = document.getElementById(t.getAttribute('aria-controls'));
                    if (tContent) tContent.hidden = true;
                }
            });

            // Desplegar/cerrar seleccionado
            trigger.setAttribute('aria-expanded', !isExpanded);
            if (content) content.hidden = isExpanded;
        });
    });

    // ======================================
    // 4. CAPTURA DE EMAIL (Vercel Endpoint)
    // ======================================
    const form = document.getElementById('subscribe-form');
    const emailInput = document.getElementById('email-input');
    const msgDisplay = document.getElementById('form-msg');
    const submitBtn = document.getElementById('submit-btn');

    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const email = emailInput.value.trim();
            const translate = window.translations ? window.translations[window.currentLang] : null;

            // Validación front
            if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                showMessage(translate ? translate.msg_invalid : 'Por favor, introduce un correo electrónico válido.', 'error');
                return;
            }

            submitBtn.disabled = true;
            submitBtn.textContent = translate ? translate.email_sending : 'Enviando...';
            msgDisplay.textContent = '';

            try {
                const response = await fetch('/api/subscribe', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email })
                });

                const data = await response.json();

                if (response.ok && data.ok) {
                    showMessage(translate ? translate.msg_success : '¡Gracias por apuntarte! Te avisaremos pronto.', 'success');
                    form.reset();
                } else {
                    showMessage(data.error || (translate ? translate.msg_error_server : 'Ocurrió un error. Inténtalo más tarde.'), 'error');
                }
            } catch (err) {
                showMessage(translate ? translate.msg_error_generic : 'Hubo un problema de conexión. Revisa tu internet e inténtalo de nuevo.', 'error');
            } finally {
                submitBtn.disabled = false;
                submitBtn.textContent = translate ? translate.email_btn : 'Avisadme';
            }
        });
    }

    function showMessage(text, type) {
        msgDisplay.textContent = text;
        msgDisplay.className = 'form-msg ' + (type === 'error' ? 'msg-error' : 'msg-success');
    }
});
