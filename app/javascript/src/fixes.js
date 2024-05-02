document.addEventListener('turbo:load', () => {
  $('a[href="#"]').click((e) => e.preventDefault());
});
