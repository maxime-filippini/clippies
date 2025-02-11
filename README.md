# Clippies

Organize your snippets and retrieve them at a moment's notice.

## Technicals

This app is built using SSR with frontend hydration for interactivity. It is using the [wisp web framework](https://github.com/gleam-wisp/wisp) on the back-end, with [lustre](https://github.com/lustre-labs/lustre) on the frontend.

This is mostly an avenue for me to learn about SSR, JS hydration and mode complex web application structures.

## To do

- [x] Make a list of authorized users in the database
- [x] Set up docker for deployments
- [ ] Define clipping categories (e.g. code, urls, etc.)
- [ ] Build search
- [ ] Redefine what needs to be passed to the client for hydration. For example, currently, the client does not need the text of each clipping because it's already in the DOM. If we want to do client-side pagination, then it would be needed.
- [ ] Spruce up the design a little bit (add header, colors, etc.)
- [ ] Add syntax highlighting for code clippings.
- [ ] Add comment that describes the clipping and would help with search.
- [ ] Give each clipping a name to ease search.
- [ ] Keep track of clipping uses to have the most useful ones at the top. This can be technically challenging, but can be done easily by storing usage in local storage and sync with DB after a certain number of clippings are copied. Storing to local storage would require some form of debouncing to avoid spamming to distort the numbers.
