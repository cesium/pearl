defmodule PearlWeb.Landing.Components.Schedule do
  @moduledoc """
  Schedule component with Calendar and Day views.
  """
  use PearlWeb, :live_component

  alias Pearl.Activities
  alias Plug.Conn.Query

  import PearlWeb.Components.Modal

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    params = Map.get(assigns, :params, %{})
    user = Map.get(assigns, :current_user)
    filters = Map.get(params, "filters", [])
    view_mode = determine_view_mode(params)

    current_date =
      determine_current_date(
        Map.get(params, "date"),
        assigns.event_start_date,
        assigns.event_end_date
      )

    view_data = prepare_view_data(view_mode, current_date, filters, assigns)

    hide_modal("activity-modal")

    socket
    |> assign(assigns)
    |> assign(
      view_mode: view_mode,
      current_date: current_date,
      filters: filters,
      user_role: get_user_role(user),
      enrolments: get_enrolments(user),
      selected_activity: nil
    )
    |> assign(view_data)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("show_details", %{"activity_id" => id}, socket) do
    activity = Activities.get_activity!(id) |> Pearl.Repo.preload(:speakers)
    {:noreply, assign(socket, :selected_activity, activity)}
  end

  @impl true
  def handle_event("enrol", %{"activity_id" => id}, socket) do
    user = socket.assigns.current_user

    case {user, user && user.type} do
      {nil, _} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("You must be logged in to enrol in activities"))
         |> redirect(to: ~p"/users/log_in?action=enrol&action_id=#{id}&return_to=/")}

      {%{type: type}, _} when type != :attendee ->
        {:noreply, put_flash(socket, :error, gettext("Only attendees can enrol in activities"))}

      {%{attendee: attendee}, :attendee} ->
        perform_enrolment(attendee.id, id, socket)
    end
  end

  @impl true
  def handle_event("modal_closed", _params, socket) do
    {:noreply, assign(socket, :selected_activity, nil)}
  end

  defp perform_enrolment(attendee_id, activity_id, socket) do
    case Activities.enrol(attendee_id, activity_id) do
      {:ok, _} ->
        send(self(), {:update_flash, {:info, gettext("Successfully enrolled")}})
        {:noreply, assign(socket, :enrolments, Activities.get_attendee_enrolments(attendee_id))}

      {:error, _} ->
        send(self(), {:update_flash, {:info, gettext("Unable to enrol")}})
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "w-full select-none min-h-screen space-y-15",
      case @view_mode do
        :calendar -> "px-5 md:pr-0 md:pl-12.5"
        :day -> "px-5 md:px-8"
      end
    ]}>
      <.schedule_header
        url={@url}
        view_mode={@view_mode}
        current_date={@current_date}
        filters={@filters}
        activity_groups={Map.get(assigns, :activity_groups, [])}
      />

      <.render_view
        view_mode={@view_mode}
        url={@url}
        days={Map.get(assigns, :days, [])}
        activity_groups={Map.get(assigns, :activity_groups, [])}
        filters={@filters}
        user_role={@user_role}
        enrolments={@enrolments}
        myself={@myself}
        calendar_pictures={Map.get(assigns, :calendar_pictures, %{})}
      />

      <.modal
        id="activity-modal"
        on_cancel={JS.push("modal_closed", target: @myself)}
        backdrop_class="backdrop-blur-xl bg-light/20"
        body_class="bg-transparent px-40 mx-auto"
        close_button_class="absolute top-2 right-2"
        close_button_button_class="-m-3 flex-none p-3 text-dark hover:opacity-70"
        close_button_icon_class="size-10"
      >
        <div :if={@selected_activity} class="flex flex-col gap-2 pt-4 w-full">
          <span class="text-4xl font-bold text-dark">
            Informações
          </span>

          <div class="flex flex-row space-x-2">
            <%= for speaker <- @selected_activity.speakers do %>
              <div
                :if={speaker.picture}
                class="relative inline-block group"
              >
                <img
                  src={Uploaders.Speaker.url({speaker.picture, speaker}, :original, signed: true)}
                  alt={speaker.name}
                  class="size-30 mt-6 mb-4 object-cover animate-[fade_in_0.5s_ease-out]"
                />

                <span class="absolute w-[95%] top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2
               bg-dark/70 text-light text-sm px-2 py-1 rounded
               opacity-0 group-hover:opacity-100 transition">
                  {speaker.name}
                </span>
              </div>
            <% end %>
          </div>

          <%!-- Activity Type --%>
          <div class="text-xl text-lightMuted font-normal">
            {get_category_name(@selected_activity)}
          </div>

          <%!-- Activity Name --%>
          <h2 class="text-3xl font-bold text-dark leading-tight mb-2 tracking-tight">
            {@selected_activity.title}
          </h2>

          <%!-- Speaker Info --%>
          <%= if length(@selected_activity.speakers) > 0 do %>
            <div class="flex flex-col items-baseline gap-x-2  text-lg -mb-2">
              <%= for speaker <- @selected_activity.speakers do %>
                <div class="flex items-baseline gap-2">
                  <span class="font-semibold text-primary">
                    {speaker.name}
                  </span>
                  <span class="text-primary/80">
                    {case {Map.get(speaker, :role), Map.get(speaker, :company)} do
                      {role, company} when is_binary(role) and is_binary(company) ->
                        "#{role} @ #{company}"

                      {role, _} when is_binary(role) ->
                        role

                      {_, company} when is_binary(company) ->
                        "@ #{company}"

                      _ ->
                        ""
                    end}
                  </span>
                </div>
              <% end %>
            </div>
          <% end %>

          <%!-- Date and Location --%>
          <div class="text-lg font-normal text-dark">
            Dia {@selected_activity.date |> Timex.format!("{D}")}, {@selected_activity.time_start
            |> Timex.format!("{h24}:{m}")}-{@selected_activity.time_end
            |> Timex.format!("{h24}:{m}")}
            <span class="mx-1">•</span>
            {@selected_activity.location}
          </div>

          <%!-- Description --%>
          <div>
            <h3 class="text-lg font-bold text-dark mb-2">
              {gettext("Descrição")}
            </h3>
            <div class="text-lightMuted text-4 w-full leading-relaxed">
              {@selected_activity.description || gettext("Sem descrição disponível.")}
            </div>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  attr :view_mode, :atom, required: true
  attr :url, :string, required: true
  attr :days, :list, default: []
  attr :activity_groups, :list, default: []
  attr :filters, :list, default: []
  attr :user_role, :atom, required: true
  attr :enrolments, :list, default: []
  attr :myself, :any, required: true
  attr :calendar_pictures, :map, default: %{}

  defp render_view(%{view_mode: :calendar} = assigns) do
    ~H"""
    <.calendar_view url={@url} days={@days} filters={@filters} calendar_pictures={@calendar_pictures} />
    """
  end

  defp render_view(%{view_mode: :day} = assigns) do
    ~H"""
    <.day_view
      activity_groups={@activity_groups}
      user_role={@user_role}
      enrolments={@enrolments}
      myself={@myself}
    />
    """
  end

  attr :url, :string, required: true
  attr :view_mode, :atom, required: true
  attr :current_date, Date, required: true
  attr :filters, :list, default: []
  attr :activity_groups, :list, default: []

  defp schedule_header(%{view_mode: :day} = assigns) do
    activities = List.flatten(assigns.activity_groups)

    counts =
      Enum.reduce(activities, %{workshops: 0, talks: 0, pitches: 0}, fn activity, acc ->
        case String.downcase(get_category_name(activity)) do
          "workshop" -> %{acc | workshops: acc.workshops + 1}
          "talk" -> %{acc | talks: acc.talks + 1}
          "pitch" -> %{acc | pitches: acc.pitches + 1}
          _ -> acc
        end
      end)

    assigns = assign(assigns, :counts, counts)

    ~H"""
    <div class="mb-10">
      <div class="text-3xl md:text-4xl font-semibold text-dark space-y-3">
        <div class="flex items-center gap-3">
          <.link
            patch={view_url(@url, :calendar, @current_date, @filters)}
            class="hover:scale-90 duration-200 flex"
          >
            <.icon name="hero-arrow-left" class="size-8" />
          </.link>
          <span>
            Dia {@current_date |> Timex.format!("{D}")}
            <span class="ml-2 md:ml-6 font-light">
              {@current_date |> Timex.lformat!("%A", "pt", :strftime)}
            </span>
          </span>
        </div>
      </div>
      <div class="text-lightMuted text-lg leading-relaxed">
        {(@view_mode == :calendar && gettext("Durante o ENEI, nunca te faltará o que fazer!")) ||
          get_day_summary(@current_date, @counts)}
      </div>
    </div>
    """
  end

  defp schedule_header(%{view_mode: :calendar} = assigns) do
    ~H"""
    <div class="mb-10">
      <div class="text-2xl md:text-4xl font-semibold text-dark mb-4">
        {gettext("Calendário")}
      </div>
      <div class="text-lightMuted text-lg leading-relaxed">
        {gettext(
          "Durante o ENEI, nunca te faltará o que fazer. Conhece nesta página o calendário detalhado e todas as atividades que temos para te oferecer."
        )}
      </div>
    </div>
    """
  end

  attr :url, :string, required: true
  attr :days, :list, required: true
  attr :filters, :list, required: true
  attr :calendar_pictures, :map, default: %{}

  defp calendar_view(assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <%= for day <- @days do %>
        <div class="flex flex-row gap-6">
          <.day_card
            url={@url}
            day={day}
            filters={@filters}
            calendar_picture={Map.get(@calendar_pictures, day)}
          />

          <div class="hidden md:flex flex-1 py-3 pr-6 bg-light overflow-x-auto scrollbar-hide">
            <div class="flex flex-row gap-1">
              <%= for time_slot <- fetch_and_group_activities(day, @filters) do %>
                <.time_slot_cell time_slot={time_slot} variant={:calendar} />
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  attr :activity_groups, :list, required: true
  attr :user_role, :atom, required: true
  attr :enrolments, :list, default: []
  attr :myself, :any, required: true

  defp day_view(assigns) do
    ~H"""
    <div class="bg-light rounded-[30px] md:rounded-[40px] p-6 md:p-10 min-h-150">
      <div class="space-y-8">
        <%= for time_slot <- @activity_groups do %>
          <.time_slot_cell
            time_slot={time_slot}
            variant={:day}
            user_role={@user_role}
            enrolments={@enrolments}
            myself={@myself}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :url, :string, required: true
  attr :day, Date, required: true
  attr :filters, :list, required: true
  attr :calendar_picture, :map, default: nil

  defp day_card(assigns) do
    is_today = Date.compare(assigns.day, Date.utc_today()) == :eq
    assigns = assign(assigns, :is_today, is_today)

    ~H"""
    <.link
      patch={view_url(@url, :day, @day, @filters)}
      class="w-full md:w-80 lg:w-100 xl:w-120 shrink-0 aspect-7/5 relative group bg-dark/60 cursor-pointer rounded-[30px] md:rounded-[40px] overflow-hidden transform transition-transform"
    >
      <div class="absolute inset-0 bg-linear-to-b from-black/40 to-black/60 z-10"></div>

      <div :if={@calendar_picture} class="absolute inset-0">
        <img
          src={
            Uploaders.Schedule.url({@calendar_picture.image, @calendar_picture}, :original,
              signed: true
            )
          }
          class="w-full h-full object-cover"
        />
      </div>

      <div class="absolute inset-0 z-20 flex flex-col justify-between p-6">
        <%= if @is_today do %>
          <div class="self-start">
            <span class="text-white text-sm font-semibold px-3 py-1 bg-white/20 rounded-full">
              {gettext("HOJE")}
            </span>
          </div>
        <% else %>
          <div></div>
        <% end %>

        <div class="flex items-end justify-between">
          <div class="text-white">
            <div class="text-3xl font-bold">
              Dia {@day |> Timex.format!("{D}")}
            </div>
            <div class="text-2xl font-light">
              {@day |> Timex.lformat!("%A", "pt", :strftime)}
            </div>
          </div>

          <.icon name="hero-arrow-right" class="size-6 text-white mb-2" />
        </div>
      </div>
    </.link>
    """
  end

  attr :time_slot, :list, required: true
  attr :variant, :atom, required: true
  attr :user_role, :atom, default: :guest
  attr :enrolments, :list, default: []
  attr :myself, :any, default: nil

  defp time_slot_cell(%{variant: :calendar} = assigns) do
    first_activity = List.first(assigns.time_slot)
    category_name = get_category_name(first_activity)
    is_break = category_name == "Break"

    assigns =
      assigns
      |> assign(:first_activity, first_activity)
      |> assign(:is_break, is_break)

    ~H"""
    <div class="flex flex-col px-6 pt-3 h-full shrink-0">
      <div class="border-olive/10 border-b-3 w-full pb-3 mb-4">
        <%= if @is_break do %>
          <div class="size-8">
            <.break_icon activity={@first_activity} />
          </div>
        <% else %>
          <div class="text-2xl font-bold text-dark">
            {@first_activity.time_start |> Timex.format!("{h24}:{m}")}-{@first_activity.time_end
            |> Timex.format!("{h24}:{m}")}
          </div>
        <% end %>
      </div>
      <div class="flex flex-row gap-6">
        <%= for activity <- @time_slot do %>
          <span class="min-w-67">
            <.activity_cell activity={activity} variant={:calendar} />
          </span>
        <% end %>
      </div>
    </div>
    """
  end

  defp time_slot_cell(%{variant: :day} = assigns) do
    first_activity = List.first(assigns.time_slot)
    category_name = get_category_name(first_activity)
    is_break = category_name == "Break"

    assigns =
      assigns
      |> assign(:first_activity, first_activity)
      |> assign(:is_break, is_break)

    ~H"""
    <div class="flex flex-col md:flex-row gap-4 md:gap-10 group">
      <div class="w-50 shrink-0 pt-1">
        <%= if @is_break do %>
          <div class="hidden md:block">
            <.break_icon activity={@first_activity} />
          </div>
        <% else %>
          <div class="text-3xl font-bold text-dark">
            {@first_activity.time_start |> Timex.format!("{h24}:{m}")}-{@first_activity.time_end
            |> Timex.format!("{h24}:{m}")}
          </div>
        <% end %>
      </div>

      <div class="flex-1 flex flex-col gap-6 md:gap-8 border-l-2 pl-5 border-light-muted">
        <%= for activity <- @time_slot do %>
          <%= if get_category_name(activity) == "Break" do %>
            <div class="flex items-center gap-3 md:hidden">
              <div class="mr-4">
                <.break_icon activity={activity} />
              </div>
              <div class="text-2xl mt-1 font-bold text-dark">{activity.title}</div>
            </div>
            <div class="hidden md:block">
              <.activity_cell
                activity={activity}
                variant={:day}
                user_role={@user_role}
                enrolments={@enrolments}
                myself={@myself}
              />
            </div>
          <% else %>
            <.activity_cell
              activity={activity}
              variant={:day}
              user_role={@user_role}
              enrolments={@enrolments}
              myself={@myself}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  attr :activity, :map, required: true
  attr :variant, :atom, required: true
  attr :user_role, :atom, default: :guest
  attr :enrolments, :list, default: []
  attr :myself, :any, default: nil

  defp activity_cell(assigns) do
    category_name = get_category_name(assigns.activity)
    is_break = category_name == "Break"

    assigns =
      assigns
      |> assign(:category_name, category_name)
      |> assign(:is_break, is_break)

    case is_break do
      true -> render_break_cell(assigns)
      false -> render_activity_cell(assigns)
    end
  end

  defp render_break_cell(assigns) do
    ~H"""
    <div class="flex flex-col" id={"activity-#{@activity.id}"}>
      <div class="text-2xl font-bold text-dark">{@activity.title}</div>
      <div class="text-lg text-lightMuted">{@activity.location}</div>
    </div>
    """
  end

  defp render_activity_cell(assigns) do
    has_speakers = length(assigns.activity.speakers) > 0
    show_actions = assigns.variant == :day

    can_enrol =
      show_actions and can_enrol?(assigns.activity, assigns.user_role, assigns.enrolments)

    is_enrolled = show_actions and already_enrolled?(assigns.activity, assigns.enrolments)

    assigns =
      assigns
      |> assign(:has_speakers, has_speakers)
      |> assign(:show_actions, show_actions)
      |> assign(:can_enrol, can_enrol)
      |> assign(:is_enrolled, is_enrolled)

    ~H"""
    <div class="flex flex-col" id={"activity-#{@activity.id}"}>
      <div class="flex flex-col items-start justify-between gap-2">
        <div class="flex-1">
          <span class="text-lg text-lightMuted font-medium mb-3">{@category_name}</span>
          <span class="text-lg font-bold text-dark">{@activity.title}</span>

          <%= if @has_speakers do %>
            <div class="text-lg text-dark mt-5">
              {case @activity.speakers do
                [] ->
                  ""

                [one] ->
                  one.name

                list ->
                  names = Enum.map(list, & &1.name)
                  Enum.join(Enum.drop(names, -1), ", ") <> " e " <> List.last(names)
              end}
            </div>
          <% end %>

          <div class="text-lightMuted">{@activity.location}</div>
        </div>

        <%= if @show_actions do %>
          <div class="flex flex-col items-end gap-3 shrink-0">
            <button
              type="button"
              phx-click={
                JS.push("show_details", value: %{activity_id: @activity.id})
                |> show_modal("activity-modal")
              }
              phx-target={@myself}
              class="flex items-center gap-2 text-base text-primary/70 hover:text-primary font-medium transition-colors"
            >
              <.icon name="hero-information-circle" class="size-5" />
              {gettext("ver informações")}
            </button>

            <%= if @can_enrol do %>
              <button
                phx-click="enrol"
                phx-target={@myself}
                phx-value-activity_id={@activity.id}
                data-confirm={gettext("Are you sure you want to enrol?")}
                class="mt-2 px-5 py-2 bg-dark text-light text-base font-bold rounded-full hover:bg-dark transition-colors"
              >
                {gettext("Inscrever")}
              </button>
            <% end %>

            <%= if @is_enrolled do %>
              <span class="mt-2 text-base font-bold text-green-600">
                {gettext("Inscrito")}
              </span>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :activity, :map, required: true

  defp break_icon(assigns) do
    name = String.downcase(assigns.activity.title)
    is_meal = String.contains?(name, ["lunch", "dinner"])

    assigns = assign(assigns, :is_meal, is_meal)

    ~H"""
    <%= if @is_meal do %>
      <div class="text-dark">
        <img
          src={~p"/images/breaks/lunch.svg"}
          class="size-7 md:size-10"
          style="filter: brightness(0);"
        />
      </div>
    <% else %>
      <div class="text-dark">
        <img
          src={~p"/images/breaks/coffee.svg"}
          class="size-7 md:size-10"
          style="filter: brightness(0);"
        />
      </div>
    <% end %>
    """
  end

  defp prepare_view_data(:calendar, _date, _filters, assigns) do
    calendar_pictures =
      Activities.list_calendar_pictures() |> Map.new(&{&1.date, &1})

    [
      days: Date.range(assigns.event_start_date, assigns.event_end_date) |> Enum.to_list(),
      calendar_pictures: calendar_pictures
    ]
  end

  defp prepare_view_data(:day, date, filters, _assigns) do
    [activity_groups: fetch_and_group_activities(date, filters)]
  end

  defp fetch_and_group_activities(day, filters) do
    Activities.list_daily_activities(day)
    |> Enum.filter(fn at -> filters == [] or at.category_id in filters end)
    |> group_activities_by_start_time()
  end

  defp group_activities_by_start_time(activities) do
    Enum.reduce(activities, [], fn activity, acc ->
      case acc do
        [] ->
          [[activity]]

        [[head | _tail] | _rest] = groups ->
          case activity.time_start == head.time_start do
            true -> prepend_to_first_group(activity, groups)
            false -> [[activity] | groups]
          end
      end
    end)
    |> Enum.reverse()
  end

  defp prepend_to_first_group(activity, [[head | tail] | rest]) do
    [[activity, head | tail] | rest]
  end

  defp can_enrol?(activity, user_role, enrolments) do
    not_full = activity.max_enrolments > activity.enrolment_count
    not_staff = user_role != :staff

    activity_start =
      NaiveDateTime.new!(activity.date, activity.time_end) |> Timex.to_datetime("Europe/Lisbon")

    future_event = DateTime.compare(activity_start, DateTime.utc_now()) != :lt

    has_conflict =
      Enum.any?(enrolments, fn e ->
        Time.compare(e.activity.time_start, activity.time_end) == :lt and
          Time.compare(e.activity.time_end, activity.time_start) == :gt and
          e.activity.date == activity.date
      end)

    activity.has_enrolments and not_full and not_staff and future_event and not has_conflict
  end

  defp already_enrolled?(activity, enrolments) do
    activity_ids = Enum.map(enrolments, & &1.activity_id)
    activity.id in activity_ids
  end

  defp determine_view_mode(%{"view" => "day"}), do: :day
  defp determine_view_mode(_params), do: :calendar

  defp determine_current_date(param_date, start_date, end_date)
       when is_binary(param_date) do
    case Date.from_iso8601(param_date) do
      {:ok, date} -> date
      _ -> default_date(start_date, end_date)
    end
  end

  defp determine_current_date(_param_date, start_date, end_date) do
    default_date(start_date, end_date)
  end

  defp default_date(start_date, end_date) do
    today = Date.utc_today()

    cond do
      Date.compare(today, start_date) == :lt -> start_date
      Date.compare(today, end_date) == :gt -> end_date
      true -> today
    end
  end

  defp get_category_name(%{category: %{name: name}}), do: name
  defp get_category_name(_), do: "Event"

  defp get_user_role(nil), do: :attendee
  defp get_user_role(%{type: type}), do: type

  defp get_enrolments(%{type: :attendee, attendee: %{id: id}}),
    do: Activities.get_attendee_enrolments(id)

  defp get_enrolments(_), do: []

  defp get_day_summary(date, counts) do
    day_name = date |> Timex.lformat!("%A", "pt", :strftime) |> String.downcase()

    parts =
      [
        {counts.workshops, "workshop", "workshops"},
        {counts.talks, "talk", "talks"},
        {counts.pitches, "pitch", "pitches"}
      ]
      |> Enum.reject(fn {count, _, _} -> count == 0 end)
      |> Enum.map(fn {count, singular, plural} ->
        "#{count} #{if count == 1, do: singular, else: plural}"
      end)

    case parts do
      [] ->
        gettext(
          "Durante o ENEI, nunca te faltará o que fazer. Conhece nesta página o calendário detalhado."
        )

      _ ->
        summary =
          case Enum.reverse(parts) do
            [last] -> last
            [last, first] -> "#{first}, #{last}"
            [last | rest] -> "#{rest |> Enum.reverse() |> Enum.join(", ")}, #{last}"
          end

        "Na #{day_name}, tens #{summary} e mais atividades."
    end
  end

  defp view_url(base_url, view_mode, current_date, filters) do
    query = %{"view" => view_mode, "date" => current_date, "filters" => filters}
    "#{base_url}?#{Query.encode(query)}"
  end
end
