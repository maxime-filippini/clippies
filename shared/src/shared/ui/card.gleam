import lustre/attribute.{attribute}
import lustre/element/html

pub fn clipping_card(text: String) {
  html.div(
    [
      attribute.class(
        "max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow-sm flex items-center justify-center",
      ),
    ],
    [html.p([attribute.class("font-normal text-gray-700")], [html.text(text)])],
  )
}
