import client
import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/json
import gleam/string_tree
import lustre/attribute
import lustre/element
import lustre/element/html
import server/web
import wisp.{type Request, type Response}

// Route handlers -----------------------------------------

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    Get, ["count", v] -> {
      let assert Ok(w) = int.parse(v)
      main_layout(w)
      |> element.to_document_string
      |> string_tree.from_string
      |> wisp.html_body(wisp.ok(), _)
    }
    _, _ -> wisp.response(200)
  }
}

// On index, we render a counter as an html shell and hydrate with the client's
// javascript

fn main_layout(v: Int) {
  html.html([], [
    html.head([], [
      html.script(
        [attribute.type_("module"), attribute.src("/static/client.min.mjs")],
        "",
      ),
      html.script(
        [attribute.type_("application/json"), attribute.id("model")],
        json.int(v)
          |> json.to_string,
      ),
    ]),
    html.body([], [
      html.div([attribute.id("app")], [client.view(client.MainPage(value: v))]),
    ]),
  ])
}
