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
  Context(static_directory: String)
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("server")
  priv_directory <> "/static"
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
