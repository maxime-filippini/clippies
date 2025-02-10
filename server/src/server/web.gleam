import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/uri
import pog
import server/auth/cookie
import server/auth/google
import server/uris
import shared/sql
import wisp.{type Request, type Response}

pub type Environment {
  Local
  Dev
  Prod
}

pub fn string_to_env(s: String) {
  case s {
    "PROD" -> Prod
    "DEV" -> Dev
    "LOCAL" -> Local
    _ -> Local
  }
}

pub type Context {
  Context(
    static_directory: String,
    google_creds: google.AuthCredentials,
    db: pog.Connection,
  )
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("server")
  priv_directory <> "/static"
}

pub fn connect_to_db(db_url: String) -> pog.Connection {
  let assert Ok(cfg) = pog.url_config(db_url)

  cfg
  |> pog.pool_size(15)
  |> pog.connect
}

pub fn middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}

pub fn with_cookie(
  req: Request,
  ctx: Context,
  handler next: fn(Request, Context, String) -> Response,
) {
  let cookie = wisp.get_cookie(req, "user_id", wisp.Signed)

  case cookie {
    Ok(user_id) -> next(req, ctx, user_id)

    Error(_) ->
      wisp.redirect(
        ctx.google_creds |> uris.auth_uri(req.path) |> uri.to_string,
      )
  }
}

pub fn require_authentication(
  req: Request,
  ctx: Context,
  handler next: fn(Request, Context, sql.FindUserRow) -> Response,
) -> Response {
  use req, ctx, user_id <- with_cookie(req, ctx)
  let assert Ok(pog.Returned(_count, rows)) = sql.find_user(ctx.db, user_id)
  io.debug(rows)

  case rows {
    [] ->
      wisp.redirect(
        ctx.google_creds |> uris.auth_uri(req.path) |> uri.to_string,
      )
    [user] -> next(req, ctx, user)
    _ -> panic
  }
}

pub fn require_json(
  request: Request,
  decoder: decode.Decoder(a),
  next: fn(a) -> Response,
) -> Response {
  use <- wisp.require_content_type(request, "application/json")
  use body <- wisp.require_string_body(request)

  case json.parse(body, decoder) {
    Ok(v) -> next(v)
    _ -> wisp.bad_request()
  }
}

fn or_400(result: Result(value, error), next: fn(value) -> Response) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(_) -> wisp.bad_request()
  }
}
