(function() {
  const indicator = document.querySelector('.scroll-indicator');
  const footer = document.querySelector('footer.site-footer');
  if (!indicator) return;

  // Hide immediately if page doesn't scroll
  function pageScrollable() {
    return document.documentElement.scrollHeight > window.innerHeight + 20; // small buffer
  }
  if (!pageScrollable()) {
    indicator.classList.add('hide');
    return;
  }

  // Intersection observer to hide when footer enters viewport
  if (footer) {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          indicator.classList.add('hide');
        } else {
          indicator.classList.remove('hide');
        }
      });
    }, { threshold: 0.1 });
    observer.observe(footer);
  }

  // Click scroll action: smooth scroll down a viewport
  indicator.addEventListener('click', () => {
    window.scrollBy({ top: window.innerHeight * 0.8, behavior: 'smooth' });
  });

  // Optional: hide after user scrolls near bottom
  window.addEventListener('scroll', () => {
    const scrollPos = window.scrollY + window.innerHeight;
    const docHeight = document.documentElement.scrollHeight;
    if (docHeight - scrollPos < 120) {
      indicator.classList.add('hide');
    }
  });
})();
