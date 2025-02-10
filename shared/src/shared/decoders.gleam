import gleam/dynamic/decode
import shared/sql

pub fn get_clippings_row_decoder() -> decode.Decoder(sql.GetClippingsRow) {
  use id <- decode.field("id", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  use text <- decode.field("text", decode.string)
  decode.success(sql.GetClippingsRow(id:, user_id:, text:))
}

pub fn clippings_decoder() -> decode.Decoder(List(sql.GetClippingsRow)) {
  get_clippings_row_decoder()
  |> decode.list
}
