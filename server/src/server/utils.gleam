import gleam/string_tree
import lustre/element.{type Element}
import wisp.{type Response}

pub fn page_to_response(page: Element(a)) -> Response {
  page
  |> element.to_document_string
  |> string_tree.from_string
  |> wisp.html_body(wisp.ok(), _)
}
