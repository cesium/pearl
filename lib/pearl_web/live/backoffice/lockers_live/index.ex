defmodule PearlWeb.Backoffice.LockersLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.Accounts
  alias Pearl.Lockers

  import PearlWeb.Components.{Table, TableSearch, Button, Modal}

  import PearlWeb.Backoffice.LockersLive.Components.{
    ScanModal,
    AttendeeModal,
    HistoryModal,
    AssignLockerModal,
    OpenLockerModal
  }

  on_mount {PearlWeb.StaffRoles,
            index: %{"attendee_lockers" => ["show"]},
            show: %{"attendee_lockers" => ["show"]},
            history: %{"attendee_lockers" => ["show"]},
            open_locker: %{"attendee_lockers" => ["edit"]},
            new_item: %{"attendee_lockers" => ["edit"]},
            config: %{"attendee_lockers" => ["config_lockers"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:modal, nil)
     |> assign(:attendee, nil)
     |> assign(:user, nil)
     |> assign(:locker, nil)
     |> assign(:locker_items, [])
     |> assign(:locker_sessions, [])
     |> assign(:active_lockers_by_attendee, %{})
     |> assign(:session_active, false)
     |> assign(:configured_lockers, false)
     |> assign(:locker_search, "")
     |> assign(:all_free_lockers, [])
     |> assign(:free_lockers, [])}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_attendees(params) do
      {:ok, {attendees, meta}} ->
        attendee_ids =
          attendees
          |> Enum.map(& &1.attendee.id)
          |> Enum.reject(&is_nil/1)

        active_lockers_by_attendee =
          if attendee_ids == [] do
            %{}
          else
            Lockers.list_active_lockers_for_attendees(attendee_ids)
          end

        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:modal, nil)
         |> assign(:active_lockers_by_attendee, active_lockers_by_attendee)
         |> assign(:current_page, :lockers)
         |> stream(:attendees, attendees, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:attendee, nil)
    |> assign(:user, nil)
    |> assign(:locker, nil)
    |> assign(:locker_items, [])
    |> assign(:locker_sessions, [])
    |> assign(:session_active, false)
  end

  defp apply_action(socket, :config, _params) do
    socket
    |> assign(:page_title, "Lockers Configuration")
  end

  defp apply_action(socket, :show, %{"attendee_id" => attendee_id}) do
    attendee = Accounts.get_attendee!(attendee_id)
    user = Accounts.get_user!(attendee.user_id)

    socket
    |> assign(:attendee, attendee)
    |> assign(:user, user)
    |> assign(:locker, nil)
    |> assign(:locker_items, [])
    |> assign(:locker_sessions, [])
    |> assign(:session_active, false)
    |> assign(:active_locker, Lockers.get_active_locker(attendee_id))
  end

  defp apply_action(socket, :history, %{"attendee_id" => attendee_id}) do
    attendee = Accounts.get_attendee!(attendee_id)
    user = Accounts.get_user!(attendee.user_id)

    socket
    |> assign(:attendee, attendee)
    |> assign(:user, user)
    |> assign(:locker, nil)
    |> assign(:locker_items, [])
    |> assign(:locker_sessions, Lockers.list_attendee_locker_history(attendee_id))
    |> assign(:session_active, false)
  end

  defp apply_action(socket, :open_locker, %{
         "attendee_id" => attendee_id,
         "session_id" => session_id
       }) do
    attendee = Accounts.get_attendee!(attendee_id)
    user = Accounts.get_user!(attendee.user_id)
    session = Lockers.get_attendee_locker!(session_id)
    locker = Lockers.get_locker!(session.locker_id)

    socket
    |> assign(:attendee, attendee)
    |> assign(:user, user)
    |> assign(:locker, locker)
    |> assign(:locker_items, Lockers.list_locker_items_by_session(session_id))
    |> assign(:locker_sessions, [])
    |> assign(:session_active, session.active)
    |> assign(:session_id, session_id)
  end

  defp apply_action(socket, :new_item, %{
         "attendee_id" => attendee_id,
         "session_id" => session_id
       }) do
    attendee = Accounts.get_attendee!(attendee_id)
    user = Accounts.get_user!(attendee.user_id)
    session = Lockers.get_attendee_locker!(session_id)
    locker = Lockers.get_locker!(session.locker_id)

    socket
    |> assign(:attendee, attendee)
    |> assign(:user, user)
    |> assign(:locker, locker)
    |> assign(:locker_items, Lockers.list_locker_items_by_session(session_id))
    |> assign(:locker_sessions, [])
    |> assign(:session_active, session.active)
    |> assign(:session_id, session_id)
    |> assign(:page_title, "New Locker Item")
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def handle_event("scan-modal", _params, socket) do
    {:noreply, assign(socket, :modal, :scan_attendee)}
  end

  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} ->
        if Accounts.credential_exists?(id) do
          if Accounts.credential_linked?(id) do
            %{id: attendee_id} = Accounts.get_attendee_from_credential(id)

            {:noreply,
             socket
             |> push_patch(to: ~p"/dashboard/attendee_lockers/#{attendee_id}")}
          else
            {:noreply,
             socket
             |> put_flash(
               :error,
               "This credential is not linked to an attendee! (400)"
             )
             |> push_patch(to: ~p"/dashboard/attendee_lockers/")}
          end
        else
          {:noreply,
           socket
           |> put_flash(:error, "This credential is not registered in the event's system! (404)")
           |> push_patch(to: ~p"/dashboard/attendee_lockers/")}
        end

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Not a valid credential! (400)")
         |> push_patch(to: ~p"/dashboard/attendee_lockers/")}
    end
  end

  def handle_event("assign-locker", %{"locker" => locker_id}, socket) do
    attendee_id = socket.assigns.attendee.id

    case Lockers.create_attendee_locker(%{
           attendee_id: attendee_id,
           locker_id: locker_id
         }) do
      {:ok, session} ->
        {:noreply,
         socket
         |> assign(:modal, nil)
         |> push_patch(to: ~p"/dashboard/attendee_lockers/#{attendee_id}/#{session.id}")}

      {:error, :locker_busy} ->
        {:noreply,
         socket
         |> put_flash(:error, "This locker is already being used!")
         |> assign(:modal, :assign_locker)}

      {:error, :attendee_busy} ->
        {:noreply,
         socket
         |> put_flash(:error, "This attendee is already using other locker!")
         |> assign(:modal, :assign_locker)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not assign locker!")
         |> assign(:modal, :assign_locker)}
    end
  end

  def handle_event("assign-locker", _params, socket) do
    configured_lockers = Lockers.lockers_configured?()
    locker_search = ""

    all_free_lockers =
      if configured_lockers do
        Lockers.list_free_lockers()
      else
        []
      end

    {:noreply,
     socket
     |> assign(:modal, :assign_locker)
     |> assign(:configured_lockers, configured_lockers)
     |> assign(:locker_search, locker_search)
     |> assign(:all_free_lockers, all_free_lockers)
     |> assign(:free_lockers, all_free_lockers)}
  end

  def handle_event("search-free-lockers", %{"locker_search" => locker_search}, socket) do
    search = locker_search |> to_string() |> String.trim()

    free_lockers =
      if search == "" do
        socket.assigns.all_free_lockers
      else
        Enum.filter(socket.assigns.all_free_lockers, fn locker ->
          locker.number
          |> to_string()
          |> String.contains?(search)
        end)
      end

    {:noreply,
     socket
     |> assign(:locker_search, locker_search)
     |> assign(:free_lockers, free_lockers)}
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply, assign(socket, :modal, nil)}
  end

  def handle_event("open-locker", _params, socket) do
    attendee_id = socket.assigns.attendee.id
    session = Lockers.get_active_attendee_locker!(attendee_id)

    {:noreply,
     socket
     |> assign(:modal, nil)
     |> push_patch(to: ~p"/dashboard/attendee_lockers/#{attendee_id}/#{session.id}")}
  end

  def handle_event("close-locker-modal", _params, socket) do
    case socket.assigns[:attendee] do
      %{id: attendee_id} ->
        {:noreply, push_patch(socket, to: ~p"/dashboard/attendee_lockers/#{attendee_id}")}

      _ ->
        {:noreply, push_patch(socket, to: ~p"/dashboard/attendee_lockers")}
    end
  end

  def handle_event("release-locker", _params, socket) do
    session = Lockers.get_attendee_locker!(socket.assigns.session_id)

    if session.active do
      case Lockers.update_attendee_locker(session, %{active: false}) do
        {:ok, _session} ->
          {:noreply,
           socket
           |> put_flash(:info, "Locker released successfully.")
           |> push_patch(to: ~p"/dashboard/attendee_lockers/#{socket.assigns.attendee.id}")}

        {:error, _changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Could not release locker session")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:info, "This locker session is already closed.")
       |> push_patch(to: ~p"/dashboard/attendee_lockers/#{socket.assigns.attendee.id}")}
    end
  end

  def handle_event("withdraw-locker-item", %{"item" => item_id}, socket) do
    item = Lockers.get_locker_item!(item_id)

    case Lockers.update_locker_item(item, %{
           stored: false,
           withdrawn_at: DateTime.utc_now()
         }) do
      {:ok, _item} ->
        case Lockers.all_withdrawn?(socket.assigns.session_id) do
          false ->
            {:noreply,
             socket
             |> assign(
               :locker_items,
               Lockers.list_locker_items_by_session(socket.assigns.session_id)
             )
             |> put_flash(:info, "Item withdrawn successfully")}

          true ->
            session = Lockers.get_attendee_locker!(socket.assigns.session_id)

            case Lockers.update_attendee_locker(session, %{active: false}) do
              {:ok, _session} ->
                {:noreply,
                 socket
                 |> put_flash(:info, "All items withdrawn. Locker session closed.")
                 |> push_patch(to: ~p"/dashboard/attendee_lockers/#{socket.assigns.attendee.id}")}

              {:error, _changeset} ->
                {:noreply,
                 socket
                 |> put_flash(:error, "Could not close locker session")}
            end
        end

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not withdraw item")}
    end
  end
end
