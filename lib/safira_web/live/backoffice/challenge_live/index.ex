defmodule PearlWeb.Backoffice.ChallengeLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.Challenges
  alias Pearl.Challenges.Challenge

  alias Pearl.Minigames

  alias PearlWeb.Helpers

  import PearlWeb.Components.Table
  import PearlWeb.Components.TableSearch

  on_mount {PearlWeb.StaffRoles,
            index: %{"challenges" => ["show"]},
            new: %{"challenges" => ["edit"]},
            edit: %{"challenges" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Challenges.list_challenges(params) do
      {:ok, {challenges, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :challenges)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:prizes, Minigames.list_prizes())
         |> stream(:challenges, challenges, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Challenge")
    |> assign(:challenge, Challenges.get_challenge!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Challenge")
    |> assign(:challenge, %Challenge{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Challenges")
    |> assign(:challenge, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    challenge = Challenges.get_challenge!(id)
    {:ok, _} = Challenges.delete_challenge(challenge)

    {:noreply, stream_delete(socket, :challenges, challenge)}
  end

  @impl true
  def handle_event("update-sorting", %{"ids" => ids}, socket) do
    ids
    |> Enum.with_index(0)
    |> Enum.each(fn {"challenges-" <> id, priority} ->
      Challenges.get_challenge!(id)
      |> Challenges.update_challenge(%{display_priority: priority})
    end)

    {:noreply, socket}
  end
end
