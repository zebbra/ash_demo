defmodule AshDemo.Repo do
  use AshPostgres.Repo,
    otp_app: :ash_demo

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions"]
  end
end
