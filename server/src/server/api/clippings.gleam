import gleam/dynamic/decode
import gleam/http.{Get, Post}
import gleam/io
import gleam/json
import pog
import server/web
import shared/sql
import wisp.{type Request, type Response}
import youid/uuid

type AddClippingPayload {
  AddClippingPayload(text: String)
}

fn add_clipping_decoder() {
  use text <- decode.field("text", decode.string)
  decode.success(AddClippingPayload(text:))
}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  use req, ctx, user <- web.require_authentication(req, ctx)
  case req.method, segments {
    Get, [] -> {
      wisp.redirect("/api/clippings/" <> user.id)
    }
    Get, [user_id] -> {
      wisp.response(200)
      |> wisp.json_body(
        get_clippings_for_user(ctx, user_id)
        |> to_json
        |> json.to_string_tree,
      )
    }

    Post, [user_id] -> {
      use payload <- web.require_json(req, add_clipping_decoder())
      add_clipping(user_id, ctx, payload.text)
    }
    _, _ -> wisp.not_found()
  }
}

fn get_clippings_for_user(
  ctx: web.Context,
  user_id: String,
) -> List(sql.GetClippingsRow) {
  let assert Ok(pog.Returned(_count, rows)) = sql.get_clippings(ctx.db, user_id)
  io.debug(rows)
  rows
}

fn to_json(clippings: List(sql.GetClippingsRow)) -> json.Json {
  json.array(clippings, fn(row) {
    json.object([
      #("id", json.string(row.id)),
      #("user_id", json.string(row.user_id)),
      #("text", json.string(row.text)),
    ])
  })
}

fn add_clipping(user_id: String, ctx: web.Context, text: String) -> Response {
  let id = uuid.v4_string()
  case sql.insert_clipping(ctx.db, id, user_id, text) {
    Ok(pog.Returned(_c, _rows)) -> wisp.response(201)
    _ -> wisp.bad_request()
  }
}
