defmodule PearlWeb.ReferralRedirectLive do
  use PearlWeb, :live_view

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    if socket.assigns.current_user do
      {:ok,
       socket
       |> push_navigate(to: ~p"/settings?referral_code=#{code}")}
    else
      {:ok,
       socket
       |> push_navigate(to: ~p"/users/register?referral_code=#{code}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen">
      <p>Redirecting...</p>
    </div>
    """
  end
end
