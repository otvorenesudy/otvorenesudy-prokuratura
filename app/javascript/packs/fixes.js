document.addEventListener("turbolinks:load", () => {
  $('a[href="#"]').click((e) => e.preventDefault());
});
