defmodule AshDemoWeb.Cldr do
  @moduledoc false
  use Cldr,
    default_locale: "en",
    locales: ["en"],
    gettext: AshDemoWeb.Gettext,
    data_dir: "./priv/cldr",
    otp_app: :ash_demo,
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime, Cldr.Unit, Cldr.List],
    generate_docs: true
end
