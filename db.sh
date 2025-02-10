source .env
cd shared
gleam run -m squirrel
mv src/sql.gleam src/shared/sql.gleam