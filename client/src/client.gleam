import gleam/json
import gleam/list
import gleam/result
import lustre
import lustre/effect.{type Effect, none}
import lustre/element.{type Element}
import plinth/browser/document
import plinth/browser/element as plelement
import shared/decoders
import shared/pages/main.{Clipping, MainPage, UserSelected} as pgmain
import shared/sql

pub fn init(flags: List(sql.GetClippingsRow)) {
  let clippings =
    flags
    |> list.map(fn(c) { pgmain.Clipping(c.id, c.text, selected: False) })
  #(MainPage(clippings:), none())
}

pub fn update(
  model: pgmain.Model,
  msg: pgmain.Msg,
) -> #(pgmain.Model, Effect(pgmain.Msg)) {
  case model, msg {
    MainPage(clippings: x), UserSelected(id: v) -> #(
      MainPage(
        clippings: x
        |> list.map(fn(c) {
          let selected = case c.selected, c.id == v {
            True, True -> False
            True, False -> True
            False, True -> True
            False, False -> False
          }

          Clipping(..c, selected:)
        }),
      ),
      none(),
    )
  }
}

pub fn view(model: pgmain.Model) -> Element(pgmain.Msg) {
  case model {
    MainPage(clippings: c) -> pgmain.view_clippings(c)
  }
}

pub fn main() {
  let json_ =
    document.query_selector("#model")
    |> result.map(plelement.inner_text)
    |> result.try(fn(x) {
      json.parse(x, decoders.clippings_decoder())
      |> result.replace_error(Nil)
    })

  let flags = case json_ {
    Ok(v) -> v
    Error(_) -> []
  }

  let app = lustre.application(init, update, view)
  lustre.start(app, "#app", flags)
}
