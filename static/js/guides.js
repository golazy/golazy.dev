document.querySelectorAll("[data-guide-version]").forEach((select) => {
  select.addEventListener("change", () => {
    window.location.assign(select.value);
  });
});
