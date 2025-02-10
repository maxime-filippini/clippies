import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri
import pages/login
import pog
import server/auth/cookie
import server/auth/google
import server/utils
import server/web
import shared/sql
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  case req.method, segments {
    Get, ["login"] -> handle_login(req, ctx)
    Get, ["callback", "google"] -> handle_callback(req, ctx)
    Get, ["logout"] -> handle_logout(req, ctx)
    _, _ -> wisp.not_found()
  }
}

fn handle_login(req: Request, ctx: web.Context) -> Response {
  login.page(ctx.google_creds) |> utils.page_to_response
}

fn handle_logout(req: Request, ctx: web.Context) -> Response {
  let resp = wisp.redirect("/")

  case wisp.get_cookie(req, "auth", wisp.Signed) {
    Ok(_value) -> cookie.with_invalidated_user_cookie(req, resp)
    Error(_) -> resp
  }
}

fn handle_callback(req: Request, ctx: web.Context) -> Response {
  let query = case req.query {
    Some(v) -> v
    None -> "state=%2F"
  }

  let redirect_to = case query |> uri.parse_query {
    Ok(qry) -> {
      let state = qry |> list.key_find("state")
      case state {
        Ok(v) -> string.replace(v, "%2F", "/")
        _ -> "/"
      }
    }
    _ -> "/"
  }

  case req.query {
    None -> wisp.not_found()
    Some(v) -> {
      let assert Ok(qry) = uri.parse_query(v)
      let assert Ok(code) = list.key_find(qry, "code")

      // Build the object obtained from sending an authorise request to the 
      // Google OAuth service
      let auth_obj = google.request_token(ctx.google_creds, code)

      // Use the Google token_info service to "validate" the token
      // (this is not real validation)
      let token_info = google.request_token_info(auth_obj.id_token)

      // TODO: This should be part of the decoding
      let email_verified = case token_info.email_verified {
        "true" -> True
        _ -> False
      }

      insert_user_if_not_in_db(ctx.db, token_info, email_verified)

      wisp.redirect(redirect_to)
      |> wisp.set_cookie(
        req,
        "user_id",
        token_info.sub,
        security: wisp.Signed,
        max_age: 24 * 60 * 60,
      )
    }
  }
}

fn insert_user_if_not_in_db(
  db: pog.Connection,
  token_info: google.TokenInfo,
  email_verified: Bool,
) {
  let assert Ok(pog.Returned(_rows_count, rows)) =
    sql.find_user(db, token_info.sub)

  case rows {
    [] -> {
      let assert Ok(pog.Returned(rows_count, _rows)) =
        sql.insert_user(
          db,
          token_info.sub,
          token_info.name,
          token_info.email,
          email_verified,
        )

      io.debug(int.to_string(rows_count) <> " rows inserted!")

      Nil
    }
    [_v, ..] -> Nil
  }
}
