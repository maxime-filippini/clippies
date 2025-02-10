import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn main_layout(
  head head: List(Element(a)),
  body body: List(Element(a)),
) -> Element(a) {
  html.html([], [
    html.head([], [
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/output.css"),
      ]),
      html.script(
        [attribute.type_("module"), attribute.src("/static/client.min.mjs")],
        "",
      ),
      ..head
    ]),
    html.body([], body),
  ])
}
