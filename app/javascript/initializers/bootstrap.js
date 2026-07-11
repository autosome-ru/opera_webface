import { Popover, Tooltip } from "bootstrap";

document.addEventListener("DOMContentLoaded", () => {
  document
    .querySelectorAll('a[rel~="popover"], .has-popover')
    .forEach(el => new Popover(el));

  document
    .querySelectorAll('a[rel~="tooltip"], .has-tooltip')
    .forEach(el => new Tooltip(el));
});
