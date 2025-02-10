import envoy
import gleam/erlang/process
import gleam/io
import mist
import router
import server/auth/google
import server/web
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")
  let assert Ok(google_creds) = google.load_credentials()
  let assert Ok(db_url) = envoy.get("DATABASE_URL")
  let ctx =
    web.Context(
      static_directory: web.static_directory(),
      google_creds:,
      db: web.connect_to_db(db_url),
    )
  let handler = router.route_request(_, ctx)

  io.debug(google_creds)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(42_069)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
