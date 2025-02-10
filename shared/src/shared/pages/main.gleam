import gleam/list
import lustre/attribute
import lustre/effect.{type Effect, none}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import shared/sql
import shared/ui/card

pub type Clipping {
  Clipping(id: String, text: String, selected: Bool)
}

pub type Model {
  MainPage(clippings: List(Clipping))
}

pub type Msg {
  UserSelected(id: String)
}

pub fn init(flags: List(sql.GetClippingsRow)) {
  let clippings =
    flags
    |> list.map(fn(c) { Clipping(c.id, c.text, selected: False) })
  #(MainPage(clippings:), none())
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
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

pub fn view(model: Model) -> Element(Msg) {
  case model {
    MainPage(clippings: c) -> view_clippings(c)
  }
}

pub fn view_clippings(rows: List(Clipping)) {
  html.div(
    [attribute.class("flex flex-wrap gap-8 w-full")],
    rows
      |> list.map(fn(row) { card.clipping_card(row.text) }),
  )
}
