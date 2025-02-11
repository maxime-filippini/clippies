import argv
import gleam/io
import simplifile

pub fn main() {
  case argv.load().arguments {
    [s] -> {
      let assert Ok(file) = simplifile.read(s)

      io.debug(file)
      Nil
    }
    _ -> io.println("")
  }
}
