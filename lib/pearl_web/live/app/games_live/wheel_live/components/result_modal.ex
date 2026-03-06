defmodule PearlWeb.App.WheelLive.Components.ResultModal do
  @moduledoc """
  Lucky wheel drop result modal component.
  """
  use PearlWeb, :component
  import PearlWeb.Components.Modal

  attr :id, :string, required: true
  attr :drop_type, :atom, required: true
  attr :drop, :map, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :wrapper_class, :string, default: ""
  attr :content_class, :string, default: "bg-primary ring-4 ring-white p-14"
  attr :show_vault_link, :boolean, default: true

  def result_modal(assigns) do
    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@content_class}
      phx-hook="Confetti"
      data-is_win={@drop_type != nil}
    >
      <div
        id={"#{@id}-content-inner"}
        class="font-terminal uppercase text-3xl md:text-4xl text-center"
      >
        <p>{get_drop_result_text(@drop_type, @drop)}</p>
      </div>

      <div
        :if={@drop_type in [:prize, :badge]}
        class="w-full py-4 px-8 sm:px-32 flex flex-row items-center justify-center"
      >
        <figure>
          <img
            :if={@drop_type == :prize}
            src={Uploaders.Prize.url({@drop.prize.image, @drop.prize}, :original, signed: true)}
            class="max-h-52"
          />
          <img
            :if={@drop_type == :badge}
            src={Uploaders.Badge.url({@drop.badge.image, @drop.badge}, :original, signed: true)}
            class="min-h-52"
          />
        </figure>
      </div>

      <div :if={@drop_type == :prize and @show_vault_link} class="font-md text-center mt-4">
        {gettext("You can redeem this prize at the accreditation by showing your")}
        <.link navigate={~p"/app/vault"} class="text-accent underline">
          {gettext("vault")}
        </.link>
      </div>
    </.modal>
    """
  end

  defp get_drop_result_text(drop_type, drop) do
    case drop_type do
      :prize ->
        gettext("Congratulations! You won %{prize_name} ✨", prize_name: drop.prize.name)

      :badge ->
        gettext("Congratulations! You won the %{badge_name} badge!", badge_name: drop.badge.name)

      :tokens ->
        if drop.tokens == 1 do
          gettext("Congratulations! You won %{tokens} token 💰!", tokens: drop.tokens)
        else
          gettext("Congratulations! You won %{tokens} tokens 💰!", tokens: drop.tokens)
        end

      :entries ->
        if drop.entries == 1 do
          gettext("Congratulations! You won 🎫 %{entries} entry to the final draw!",
            entries: drop.entries
          )
        else
          gettext("Congratulations! You won 🎫 %{entries} entries to the final draw!",
            entries: drop.entries
          )
        end

      _ ->
        gettext("Oops.. You didn't win anything.. Maybe try again? 👀")
    end
  end
end
