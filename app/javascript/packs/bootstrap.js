document.addEventListener("turbolinks:load", () => {
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
});
