export function writeToClipboard(id) {
  var copyText = document.getElementById(id);
  navigator.clipboard.writeText(copyText.innerText);
}
