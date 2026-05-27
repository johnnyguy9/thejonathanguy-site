/* TheJonathanGuy.com
   Mobile nav, reveal animation, carousel sliders, and photo lightbox. */

(function () {
  'use strict';

  function toArray(list) {
    return Array.prototype.slice.call(list || []);
  }

  function getCurrentIndex(slides) {
    for (var i = 0; i < slides.length; i += 1) {
      if (slides[i].classList.contains('is-active')) return i;
    }
    return 0;
  }

  // Mobile nav toggle
  var toggle = document.querySelector('.nav-toggle');
  var panel = document.querySelector('.mobile-panel');
  if (toggle && panel) {
    toggle.addEventListener('click', function () {
      var open = panel.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', open);
    });
    toArray(panel.querySelectorAll('a')).forEach(function (link) {
      link.addEventListener('click', function () {
        panel.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // Scroll-triggered reveal
  var revealEls = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && revealEls.length) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-in');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
    toArray(revealEls).forEach(function (el) { io.observe(el); });
  } else {
    toArray(revealEls).forEach(function (el) { el.classList.add('is-in'); });
  }

  // Shared photo carousels and lightbox
  var carousels = toArray(document.querySelectorAll('[data-carousel]'));
  var lightbox = document.querySelector('[data-lightbox]');
  var lightboxImage = lightbox ? lightbox.querySelector('.lightbox-image') : null;
  var lightboxTitle = lightbox ? lightbox.querySelector('.lightbox-title') : null;
  var lightboxCaption = lightbox ? lightbox.querySelector('.lightbox-caption') : null;
  var lightboxCounter = lightbox ? lightbox.querySelector('.lightbox-counter') : null;
  var lightboxPrev = lightbox ? lightbox.querySelector('[data-lightbox-prev]') : null;
  var lightboxNext = lightbox ? lightbox.querySelector('[data-lightbox-next]') : null;
  var lightboxClose = lightbox ? lightbox.querySelector('[data-lightbox-close]') : null;

  var activeCarousel = null;
  var activeIndex = 0;
  var previousFocus = null;

  function setCarouselState(carousel, nextIndex) {
    var slides = toArray(carousel.querySelectorAll('.carousel-slide'));
    var thumbs = toArray(carousel.querySelectorAll('.carousel-thumb'));
    var title = carousel.querySelector('.carousel-title');
    var caption = carousel.querySelector('.carousel-caption');
    var counter = carousel.querySelector('.carousel-counter');
    var total = slides.length;

    if (!total) return;

    if (nextIndex < 0) nextIndex = total - 1;
    if (nextIndex >= total) nextIndex = 0;

    slides.forEach(function (slide, index) {
      var isActive = index === nextIndex;
      slide.classList.toggle('is-active', isActive);
      slide.setAttribute('aria-hidden', isActive ? 'false' : 'true');
    });

    thumbs.forEach(function (thumb, index) {
      var isActive = index === nextIndex;
      thumb.classList.toggle('is-active', isActive);
      thumb.setAttribute('aria-pressed', isActive ? 'true' : 'false');
    });

    if (counter) counter.textContent = String(nextIndex + 1) + ' / ' + String(total);
    if (title) title.textContent = slides[nextIndex].getAttribute('data-title') || '';
    if (caption) caption.textContent = slides[nextIndex].getAttribute('data-caption') || '';

    carousel.setAttribute('data-current-index', String(nextIndex));
  }

  function openLightbox(carousel, slideIndex, trigger) {
    if (!lightbox || !lightboxImage) return;

    activeCarousel = carousel;
    activeIndex = slideIndex;
    previousFocus = trigger || document.activeElement;
    syncLightbox();
    lightbox.hidden = false;
    document.body.classList.add('lightbox-open');
    if (lightboxClose) lightboxClose.focus();
  }

  function closeLightbox() {
    if (!lightbox) return;
    lightbox.hidden = true;
    document.body.classList.remove('lightbox-open');
    if (previousFocus && typeof previousFocus.focus === 'function') previousFocus.focus();
  }

  function syncLightbox() {
    if (!activeCarousel || !lightboxImage) return;

    var slides = toArray(activeCarousel.querySelectorAll('.carousel-slide'));
    if (!slides.length) return;
    if (activeIndex < 0) activeIndex = slides.length - 1;
    if (activeIndex >= slides.length) activeIndex = 0;

    var slide = slides[activeIndex];
    var image = slide.querySelector('img');

    if (!image) return;

    setCarouselState(activeCarousel, activeIndex);

    lightboxImage.src = image.getAttribute('src') || '';
    lightboxImage.alt = image.getAttribute('alt') || '';
    if (lightboxTitle) lightboxTitle.textContent = slide.getAttribute('data-title') || '';
    if (lightboxCaption) lightboxCaption.textContent = slide.getAttribute('data-caption') || '';
    if (lightboxCounter) lightboxCounter.textContent = String(activeIndex + 1) + ' / ' + String(slides.length);
  }

  if (lightbox) {
    if (lightboxClose) lightboxClose.addEventListener('click', closeLightbox);
    if (lightboxPrev) {
      lightboxPrev.addEventListener('click', function () {
        activeIndex -= 1;
        syncLightbox();
      });
    }
    if (lightboxNext) {
      lightboxNext.addEventListener('click', function () {
        activeIndex += 1;
        syncLightbox();
      });
    }
    lightbox.addEventListener('click', function (event) {
      if (event.target === lightbox) closeLightbox();
    });
    document.addEventListener('keydown', function (event) {
      if (!lightbox || lightbox.hidden) return;
      if (event.key === 'Escape') closeLightbox();
      if (event.key === 'ArrowLeft') {
        activeIndex -= 1;
        syncLightbox();
      }
      if (event.key === 'ArrowRight') {
        activeIndex += 1;
        syncLightbox();
      }
    });
  }

  carousels.forEach(function (carousel) {
    var slides = toArray(carousel.querySelectorAll('.carousel-slide'));
    var thumbs = toArray(carousel.querySelectorAll('.carousel-thumb'));
    var prev = carousel.querySelector('[data-carousel-prev]');
    var next = carousel.querySelector('[data-carousel-next]');
    var intervalMs = parseInt(carousel.getAttribute('data-interval') || '6500', 10);
    var autoplay = carousel.getAttribute('data-autoplay') === 'true' && slides.length > 1;
    var timer = null;

    setCarouselState(carousel, getCurrentIndex(slides));

    if (prev) {
      prev.addEventListener('click', function () {
        setCarouselState(carousel, parseInt(carousel.getAttribute('data-current-index') || '0', 10) - 1);
      });
    }

    if (next) {
      next.addEventListener('click', function () {
        setCarouselState(carousel, parseInt(carousel.getAttribute('data-current-index') || '0', 10) + 1);
      });
    }

    thumbs.forEach(function (thumb, index) {
      thumb.addEventListener('click', function () {
        setCarouselState(carousel, index);
      });
    });

    slides.forEach(function (slide, index) {
      var trigger = slide.querySelector('.carousel-zoom');
      if (!trigger) return;
      trigger.addEventListener('click', function () {
        openLightbox(carousel, index, trigger);
      });
    });

    function stopAutoplay() {
      if (timer) {
        window.clearInterval(timer);
        timer = null;
      }
    }

    function startAutoplay() {
      if (!autoplay) return;
      stopAutoplay();
      timer = window.setInterval(function () {
        setCarouselState(carousel, parseInt(carousel.getAttribute('data-current-index') || '0', 10) + 1);
      }, intervalMs);
    }

    carousel.addEventListener('mouseenter', stopAutoplay);
    carousel.addEventListener('mouseleave', startAutoplay);
    carousel.addEventListener('focusin', stopAutoplay);
    carousel.addEventListener('focusout', function (event) {
      if (!carousel.contains(event.relatedTarget)) startAutoplay();
    });

    startAutoplay();
  });

  // Footer year
  var year = document.getElementById('current-year');
  if (year) year.textContent = new Date().getFullYear();
})();
