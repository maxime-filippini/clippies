import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pages/layout
import server/auth/google
import server/uris

fn log_in_button(auth_href: String) -> Element(Nil) {
  html.a([attribute.href(auth_href)], [html.text("Log in with Google")])
}

// fn log_out_button(href: String) -> Element(Nil) {
//   html.div([], [html.a([attribute.href(href)], [html.text("Log out")])])
// }

pub fn page(google_creds: google.AuthCredentials) -> Element(Nil) {
  let body = [
    google_creds
    |> uris.auth_uri("")
    |> uri.to_string
    |> log_in_button,
  ]

  let head = []
  layout.main_layout(head:, body:)
}
