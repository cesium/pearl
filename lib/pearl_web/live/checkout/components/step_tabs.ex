defmodule PearlWeb.Checkout.Components.StepTabs do
  use PearlWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex gap-3 bg-[#EFEFED]">
      <div :for={{tab, i} <- Enum.with_index(@tabs)}>
        <div class={[
          "w-40 flex border-b-2 border-black/5 text-black py-2.5 gap-2",
          is_current_action(tab, @action) && "border-primary"
        ]}>
          <div class={[
            "w-6 h-6 flex items-center justify-center bg-black/5",
            is_current_action(tab, @action) && "bg-primary"
          ]}>
            <span class={["text-sm", is_current_action(tab, @action) && "text-white"]}>{i + 1}</span>
          </div>
          <span class={[is_current_action(tab, @action) && "text-primary"]}>
            {String.capitalize(Atom.to_string(tab))}
          </span>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:tabs, [])}
  end

  @impl true
  def handle_event("select_tab", _params, socket) do
    {:noreply, socket}
  end

  defp is_current_action(tab, action), do: tab == action
end
