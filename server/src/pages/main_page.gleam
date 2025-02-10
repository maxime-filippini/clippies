import gleam/json
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pages/layout
import shared/encoders
import shared/pages/main as pgmain
import shared/sql

pub fn main_page(clippings: List(sql.GetClippingsRow)) -> Element(pgmain.Msg) {
  let body = [
    html.div([attribute.id("app")], [
      pgmain.view(pgmain.MainPage(
        clippings: clippings
        |> list.map(fn(row) {
          pgmain.Clipping(id: row.id, text: row.text, selected: False)
        }),
      )),
    ]),
  ]

  let head = [
    html.script(
      [attribute.type_("application/json"), attribute.id("model")],
      encoders.clippings(clippings) |> json.to_string,
    ),
  ]
  layout.main_layout(head:, body:)
}
