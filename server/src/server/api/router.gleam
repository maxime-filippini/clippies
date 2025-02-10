import server/api/clippings
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  case segments {
    ["clippings", ..segments] -> clippings.handle_request(req, ctx, segments)
    _ -> wisp.not_found()
  }
}
