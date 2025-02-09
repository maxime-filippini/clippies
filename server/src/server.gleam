import gleam/erlang/process
import mist
import router
import server/web
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let ctx = web.Context(static_directory: web.static_directory())

  let handler = router.route_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, wisp.random_string(64))
    |> mist.new
    |> mist.port(42_069)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
