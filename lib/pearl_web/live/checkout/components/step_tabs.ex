defmodule PearlWeb.Checkout.Components.StepTabs do
  @moduledoc """
    Tabs for the checkout flow
  """
  use PearlWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex gap-3 bg-[#EFEFED]">
      <div :for={{tab, i} <- Enum.with_index(@tabs)}>
        <div class={[
          "w-40 flex border-b-2 border-black/5 text-black py-2.5 gap-2",
          current_action?(tab, @action) && "border-primary"
        ]}>
          <div class={[
            "w-6 h-6 flex items-center justify-center bg-black/5",
            current_action?(tab, @action) && "bg-primary"
          ]}>
            <span class={["text-sm", current_action?(tab, @action) && "text-white"]}>{i + 1}</span>
          </div>
          <span class={[current_action?(tab, @action) && "text-primary"]}>
            {get_tab_name(tab)}
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

  defp current_action?(tab, action), do: tab == action

  defp get_tab_name(:new), do: "Registo"
  defp get_tab_name(:confirm_email), do: "Confirmar email"
  defp get_tab_name(:verification), do: "Verificação"
  defp get_tab_name(:choose_ticket), do: "Tipo de bilhete"
  defp get_tab_name(:precautions), do: "Precauções"
  defp get_tab_name(:informations), do: "Informações"
  defp get_tab_name(:conclusion), do: "Conclusão"
end
