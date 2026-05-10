/* =============================================================
   VANELUX FX - Premium interactions
   ============================================================= */

(function() {
  'use strict';

  // ============================================================
  // Particles generator
  // ============================================================
  function initParticles(count = 25) {
    const container = document.querySelector('.vx-particles');
    if (!container) return;
    
    for (let i = 0; i < count; i++) {
      const p = document.createElement('div');
      p.className = 'vx-particle';
      p.style.left = Math.random() * 100 + '%';
      p.style.animationDelay = Math.random() * 10 + 's';
      p.style.animationDuration = (8 + Math.random() * 8) + 's';
      const size = 1 + Math.random() * 3;
      p.style.width = size + 'px';
      p.style.height = size + 'px';
      p.style.opacity = 0.3 + Math.random() * 0.7;
      container.appendChild(p);
    }
  }

  // ============================================================
  // Scroll reveal (IntersectionObserver)
  // ============================================================
  function initScrollReveal() {
    const elements = document.querySelectorAll('.vx-reveal');
    if (!elements.length) return;
    
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, i) => {
        if (entry.isIntersecting) {
          setTimeout(() => entry.target.classList.add('visible'), i * 80);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -60px 0px' });
    
    elements.forEach(el => observer.observe(el));
  }

  // ============================================================
  // Nav scroll effect
  // ============================================================
  function initNavScroll() {
    const nav = document.querySelector('.vx-nav');
    if (!nav) return;
    
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
      const scrolled = window.scrollY > 60;
      nav.classList.toggle('scrolled', scrolled);
      lastScroll = window.scrollY;
    }, { passive: true });
  }

  // ============================================================
  // Magnetic buttons (subtle hover)
  // ============================================================
  function initMagneticButtons() {
    const buttons = document.querySelectorAll('.vx-btn-primary');
    buttons.forEach(btn => {
      btn.addEventListener('mousemove', (e) => {
        const rect = btn.getBoundingClientRect();
        const x = e.clientX - rect.left - rect.width / 2;
        const y = e.clientY - rect.top - rect.height / 2;
        btn.style.transform = `translate(${x * 0.15}px, ${y * 0.15}px) translateY(-3px)`;
      });
      btn.addEventListener('mouseleave', () => {
        btn.style.transform = '';
      });
    });
  }

  // ============================================================
  // Counter animation
  // ============================================================
  function initCounters() {
    const counters = document.querySelectorAll('.vx-stat-number[data-count]');
    if (!counters.length) return;
    
    const animate = (el) => {
      const target = parseFloat(el.dataset.count);
      const suffix = el.dataset.suffix || '';
      const duration = 2000;
      const start = performance.now();
      
      const tick = (now) => {
        const progress = Math.min((now - start) / duration, 1);
        const ease = 1 - Math.pow(1 - progress, 3);
        const value = target * ease;
        el.textContent = (Number.isInteger(target) ? Math.floor(value) : value.toFixed(1)) + suffix;
        if (progress < 1) requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    };
    
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animate(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });
    
    counters.forEach(c => observer.observe(c));
  }

  // ============================================================
  // Parallax orbs follow mouse subtly
  // ============================================================
  function initOrbParallax() {
    const orbs = document.querySelectorAll('.vx-orb');
    if (!orbs.length) return;
    if (window.matchMedia('(hover: none)').matches) return;
    
    document.addEventListener('mousemove', (e) => {
      const x = (e.clientX / window.innerWidth - 0.5) * 2;
      const y = (e.clientY / window.innerHeight - 0.5) * 2;
      orbs.forEach((orb, i) => {
        const depth = (i + 1) * 15;
        orb.style.transform = `translate(${x * depth}px, ${y * depth}px)`;
      });
    }, { passive: true });
  }

  // ============================================================
  // Smooth scroll for anchors
  // ============================================================
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(link => {
      link.addEventListener('click', (e) => {
        const target = document.querySelector(link.getAttribute('href'));
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  // ============================================================
  // Init all
  // ============================================================
  function init() {
    initParticles();
    initScrollReveal();
    initNavScroll();
    initMagneticButtons();
    initCounters();
    initOrbParallax();
    initSmoothScroll();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
