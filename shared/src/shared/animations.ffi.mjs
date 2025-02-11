export function flashColor(id, color, duration) {
  requestAnimationFrame(() => {
    let elt = document.getElementById(id);
    elt.classList.add(color);

    setTimeout(() => {
      elt.classList.remove(color);
    }, duration);
  });
}
