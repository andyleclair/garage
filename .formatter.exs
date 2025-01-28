[
  import_deps: [
    :oban,
    :ecto,
    :ecto_sql,
    :phoenix,
    :ash,
    :ash_admin,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ash_phoenix,
    :ash_postgres
  ],
  locals_without_parens: [oban_dashboard: 1],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/*.exs"]
]
