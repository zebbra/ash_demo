[
  import_deps: [:ash_postgres, :ash, :ecto, :ecto_sql, :phoenix, :ash_phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Styler, Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
