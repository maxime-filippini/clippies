import gleam/json
import shared/sql

pub fn clippings(lst: List(sql.GetClippingsRow)) -> json.Json {
  json.array(lst, fn(row) {
    json.object([
      #("id", json.string(row.id)),
      #("user_id", json.string(row.user_id)),
      #("text", json.string(row.text)),
    ])
  })
}
