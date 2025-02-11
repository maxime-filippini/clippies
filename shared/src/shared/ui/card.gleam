import lustre/attribute.{attribute}
import lustre/element/html

pub fn clipping_card(id: String, text: String) {
  html.div(
    [
      attribute.class(
        "p-6 bg-white border border-gray-200 rounded-lg shadow-sm sm:w-auto w-full transition duration-500 ease-in-out",
      ),
      attribute.id(id),
    ],
    [
      html.pre([attribute.class("text-gray-700 whitespace-pre")], [
        html.code([], [html.text(text)]),
      ]),
    ],
  )
}
