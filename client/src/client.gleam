import gleam/json
import gleam/result
import lustre
import plinth/browser/document
import plinth/browser/element as plelement
import shared/decoders
import shared/pages/main.{init, update, view}

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
