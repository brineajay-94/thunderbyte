import React, { useEffect, useRef } from 'react';

interface Flake {
    x: number;
    y: number;
    r: number;
    speed: number;
    swayAmp: number;
    swayFreq: number;
    swayPhase: number;
    alpha: number;
    depth: number;
}

const Snowfall = () => {
    const canvasRef = useRef<HTMLCanvasElement>(null);

    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        if (!ctx) return;

        if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

        const isMobile = window.matchMedia('(max-width: 768px)').matches;
        const FLAKE_COUNT = isMobile ? 22 : 45;

        let W = 0;
        let H = 0;
        let dpr = 1;
        let flakes: Flake[] = [];
        let rafId: number | null = null;
        let lastTime = 0;

        const rand = (min: number, max: number) => Math.random() * (max - min) + min;

        const resize = () => {
            dpr = Math.min(window.devicePixelRatio || 1, 2);
            W = canvas.clientWidth;
            H = canvas.clientHeight;
            canvas.width = Math.floor(W * dpr);
            canvas.height = Math.floor(H * dpr);
            ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        };

        const createFlake = (initial: boolean): Flake => {
            const depth = Math.random();

            return {
                x: rand(0, W),
                y: initial ? rand(-H, H) : rand(-40, -10),
                r: depth * 2.1 + 0.9,
                speed: depth * 0.55 + 0.22,
                swayAmp: depth * 22 + 6,
                swayFreq: rand(0.0006, 0.0014),
                swayPhase: rand(0, Math.PI * 2),
                alpha: depth * 0.55 + 0.25,
                depth,
            };
        };

        const buildFlakes = () => {
            flakes = [];
            for (let i = 0; i < FLAKE_COUNT; i++) {
                flakes.push(createFlake(true));
            }
        };

        const drawFlake = (f: Flake, time: number) => {
            const sway = Math.sin(time * f.swayFreq + f.swayPhase) * f.swayAmp;

            ctx.save();
            ctx.globalAlpha = f.alpha;

            const grad = ctx.createRadialGradient(f.x + sway, f.y, 0, f.x + sway, f.y, f.r * 3);
            grad.addColorStop(0, 'rgba(255,255,255,' + f.alpha + ')');
            grad.addColorStop(0.4, 'rgba(220,235,255,' + (f.alpha * 0.5) + ')');
            grad.addColorStop(1, 'rgba(255,255,255,0)');

            ctx.fillStyle = grad;
            ctx.beginPath();
            ctx.arc(f.x + sway, f.y, f.r * 3, 0, Math.PI * 2);
            ctx.fill();

            if (f.depth > 0.35) {
                ctx.globalAlpha = Math.min(1, f.alpha * 1.3);
                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.arc(f.x + sway, f.y, f.r * 0.55, 0, Math.PI * 2);
                ctx.fill();
            }

            ctx.restore();
        };

        const update = (delta: number) => {
            const factor = delta / 16.67;
            for (let i = 0; i < flakes.length; i++) {
                const f = flakes[i];
                f.y += f.speed * factor;
                if (f.y - f.r * 3 > H + 20) {
                    flakes[i] = createFlake(false);
                }
            }
        };

        const render = (time: number) => {
            ctx.clearRect(0, 0, W, H);
            for (let i = 0; i < flakes.length; i++) {
                drawFlake(flakes[i], time);
            }
        };

        const loop = (time: number) => {
            if (!lastTime) lastTime = time;
            const delta = Math.min(time - lastTime, 48);
            lastTime = time;

            update(delta);
            render(time);

            rafId = requestAnimationFrame(loop);
        };

        const start = () => {
            resize();
            buildFlakes();
            if (rafId !== null) cancelAnimationFrame(rafId);
            lastTime = 0;
            rafId = requestAnimationFrame(loop);
        };

        const stop = () => {
            if (rafId !== null) cancelAnimationFrame(rafId);
            rafId = null;
        };

        let resizeTimer: number | null = null;
        const onResize = () => {
            if (resizeTimer !== null) window.clearTimeout(resizeTimer);
            resizeTimer = window.setTimeout(() => {
                resize();
                buildFlakes();
            }, 180);
        };

        const onVisibility = () => {
            if (document.hidden) stop();
            else start();
        };

        window.addEventListener('resize', onResize);
        document.addEventListener('visibilitychange', onVisibility);
        start();

        return () => {
            window.removeEventListener('resize', onResize);
            document.removeEventListener('visibilitychange', onVisibility);
            stop();
        };
    }, []);

    return (
        <canvas
            ref={canvasRef}
            aria-hidden={true}
            style={{
                position: 'absolute',
                inset: 0,
                width: '100%',
                height: '100%',
                zIndex: 1,
                pointerEvents: 'none',
                opacity: 0.85,
            }}
        />
    );
};

export default Snowfall;