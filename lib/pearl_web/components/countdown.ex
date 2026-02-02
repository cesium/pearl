defmodule PearlWeb.Components.Countdown do
  @moduledoc false
  use PearlWeb, :component

  attr :target_datetime, :any, required: true

  def countdown(%{target_datetime: target} = assigns) do
    now = DateTime.utc_now()
    target_dt = normalize_to_datetime!(target)

    # if target already passed, clamp to 0
    seconds_left = max(DateTime.diff(target_dt, now, :second), 0)

    months_left = div(seconds_left, 30 * 24 * 60 * 60)
    days_left = div(rem(seconds_left, 30 * 24 * 60 * 60), 24 * 60 * 60)
    hours_left = div(rem(seconds_left, 24 * 60 * 60), 60 * 60)

    assigns =
      assigns
      |> assign(:months_left, months_left)
      |> assign(:days_left, days_left)
      |> assign(:hours_left, hours_left)

    ~H"""
    <div class="flex flex-row items-center">
      <.section label="Meses" value={@months_left} />
      <.section label="Dias" value={@days_left} />
      <.section label="Horas" value={@hours_left} is_last />
    </div>
    """
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :is_last, :boolean, default: false

  defp section(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="flex flex-col items-center">
        <div class="flex flex-row font-semibold text-3xl gap-1">
          <.digit_card digit={div(@value, 10)} />
          <.digit_card digit={rem(@value, 10)} />
        </div>
        <p class="text-sm mt-1 lowercase opacity-30">{@label}</p>
      </div>
      <%= unless @is_last do %>
        <p class="text-3xl font-semibold mx-2 mt-1">:</p>
      <% end %>
    </div>
    """
  end

  defp digit_card(assigns) do
    ~H"""
    <p class="bg-black/7 px-2 py-2 rounded-lg">{@digit}</p>
    """
  end

  defp normalize_to_datetime!(%DateTime{} = dt), do: dt

  defp normalize_to_datetime!(%NaiveDateTime{} = ndt) do
    DateTime.from_naive!(ndt, "Etc/UTC")
  end

  defp normalize_to_datetime!(%Date{} = date) do
    date
    |> NaiveDateTime.new!(~T[00:00:00])
    |> DateTime.from_naive!("Etc/UTC")
  end
end
