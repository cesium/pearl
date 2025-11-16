defmodule PearlWeb.Presence do
  @moduledoc """
  Wrapper for `Phoenix.Presence` to use in Pearl.
  """
  use Phoenix.Presence, otp_app: :pearl, pubsub_server: Pearl.PubSub

  alias Phoenix.PubSub

  @topic "presence:pearl"
  @pubsub Pearl.PubSub

  def list_presences, do: list(@topic)

  def add_presence(pid, id, data), do: track(pid, @topic, id, data)

  def subscribe, do: PubSub.subscribe(@pubsub, @topic)
end
