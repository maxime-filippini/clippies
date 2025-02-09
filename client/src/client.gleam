import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import lustre
import lustre/effect.{type Effect, none}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event.{on_click}
import plinth/browser/document
import plinth/browser/element as plelement

pub type Model {
  MainPage(value: Int)
}

pub type Msg {
  Incr
  Decr
}

pub fn init(flags) {
  io.debug(flags)
  #(MainPage(value: flags), none())
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case model, msg {
    MainPage(value: v), Incr -> #(MainPage(value: v + 1), none())
    MainPage(value: v), Decr -> #(MainPage(value: v - 1), none())
  }
}

pub fn view(model: Model) -> Element(Msg) {
  case model {
    MainPage(value: v) ->
      html.div([], [
        html.p([], [
          v
          |> int.to_string
          |> html.text,
        ]),
        html.button([on_click(Decr)], [html.text("-")]),
        html.button([on_click(Incr)], [html.text("+")]),
      ])
  }
}

pub fn main() {
  let json_ =
    document.query_selector("#model")
    |> result.map(plelement.inner_text)
    |> result.try(fn(x) {
      json.parse(x, decode.int) |> result.replace_error(Nil)
    })

  io.debug(json_)

  let flags = case json_ {
    Ok(count) -> count
    Error(_) -> 0
  }

  let app = lustre.application(init, update, view)
  lustre.start(app, "#app", flags)
}
