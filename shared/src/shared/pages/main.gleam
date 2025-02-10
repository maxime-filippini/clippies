import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub type Clipping {
  Clipping(id: String, text: String, selected: Bool)
}

pub type Model {
  MainPage(clippings: List(Clipping))
}

pub type Msg {
  UserSelected(id: String)
}

pub fn view_clippings(rows: List(Clipping)) {
  html.ul(
    [],
    rows
      |> list.map(fn(row) {
        let color = case row.selected {
          True -> "bg-violet-50"
          False -> "bg-slate-50"
        }

        html.button(
          [event.on_click(UserSelected(row.id)), attribute.class(color)],
          [html.text(row.text)],
        )
      }),
  )
}

pub fn view(model: Model) -> Element(Msg) {
  case model {
    MainPage(clippings: c) -> view_clippings(c)
  }
}
