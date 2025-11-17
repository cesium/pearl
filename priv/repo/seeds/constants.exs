defmodule Pearl.Repo.Seeds.Constants do
  alias Pearl.Constants
  alias Pearl.Event

  def run do
    Constants.set("registrations_open", "true")
    Constants.set("start_time", "2024-09-29T17:57:00Z")

    for k <- Event.feature_flag_keys() do
      Constants.set(k, "true")
    end

    Constants.set("call_for_staff_enabled", "false")
  end
end

Pearl.Repo.Seeds.Constants.run()
