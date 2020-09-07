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
};

document.addEventListener("turbolinks:load", listener);
document.addEventListener("suggest:load", listener);
