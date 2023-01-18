defmodule WabiSabiEx.Repo do
  use Ecto.Repo,
    otp_app: :wabi_sabi_ex,
    adapter: Ecto.Adapters.Postgres
end
