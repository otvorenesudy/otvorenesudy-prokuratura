const listener = () => {
  const options = {
    html: true,
    container: "body",
    constraints: [
      {
        to: "scrollParent",
        attachment: "together",
        pin: true,
      },
    ],
  };

  $('[data-toggle="tooltip"]').tooltip(options);
  $('[data-toggle="popover"]').popover(options);

  $(".collapse").on("show.bs.collapse", (event) => event.stopPropagation());
  $(".collapse").on("hide.bs.collapse", (event) => event.stopPropagation());

  $('a[data-toggle="tab"]').on("shown.bs.tab", ({ target: element }) => {
    if (element.getAttribute("data-active-title")) {
      element.setAttribute("data-inactive-title", element.textContent);
      element.textContent = element.getAttribute("data-active-title");
    }
  });

  $('a[data-toggle="tab"]').on("hidden.bs.tab", ({ target: element }) => {
    if (element.getAttribute("data-inactive-title")) {
      element.textContent = element.getAttribute("data-inactive-title");
      element.removeAttribute("data-inactive-title");
    }
  });

  document
    .querySelectorAll('a.active[data-toggle="tab"][data-active-title]')
    .forEach((element) => $(element).trigger("shown.bs.tab"));
};

document.addEventListener("turbolinks:load", listener);
document.addEventListener("suggest:load", listener);
