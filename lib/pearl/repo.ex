defmodule Pearl.Repo do
  use Ecto.Repo,
    otp_app: :pearl,
    adapter: Ecto.Adapters.Postgres
end
