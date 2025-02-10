import gleam/http.{Get}
import gleam/int
import pages/main_page
import pog
import server/api/router as api_router
import server/auth/router as auth_router
import server/utils
import server/web
import shared/encoders
import shared/sql
import wisp.{type Request, type Response}

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    Get, ["auth", ..segments] -> auth_router.handle_request(req, ctx, segments)
    _, ["api", ..segments] -> api_router.handle_request(req, ctx, segments)

    Get, segments -> handle_index_request(req, ctx, segments)

    _, _ -> wisp.response(200)
  }
}

fn handle_index_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  case req.method, segments {
    Get, [] -> {
      use _req, _resp, user <- web.require_authentication(req, ctx)

      // Load the clippings
      let assert Ok(pog.Returned(_count, rows)) =
        sql.get_clippings(ctx.db, user.id)

      main_page.main_page(rows)
      |> utils.page_to_response
    }
    _, _ -> wisp.not_found()
  }
}
