defmodule PearlWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  use Gettext, backend: PearlWeb.Gettext

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-101 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.backoffice_button>Save</.backoffice_button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"
  attr :class, :string, default: "", doc: "extra classes for the form element"

  attr :wrapper_class, :string,
    default: "mt-10 space-y-8",
    doc: "classes for the inner wrapper div"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest} class={@class}>
      <div class={@wrapper_class}>
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-dark text-light dark:bg-light dark:text-dark hover:bg-darkShade dark:hover:bg-lightShade/95 py-2 px-3",
        "text-sm font-semibold leading-6 transition-colors",
        @rest[:disabled] && "opacity-50 cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.
  ...
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :label_class, :string, default: nil
  attr :value, :any

  # Add this new attribute
  attr :variant, :atom, values: [:default, :flushed], default: :default

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range radio segmented-radio search select tel text textarea time url week handle)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  attr :wrapper_class, :string, default: ""
  attr :class, :string, default: ""

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <label class="flex items-center gap-3 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={"rounded border-zinc-300 text-primary focus:ring-0 #{@class}"}
          {@rest}
        />
        <span class="leading-normal">{@label}</span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <.label for={@id} class={@label_class}>{@label}</.label>
      <div class="mt-5 flex flex-col gap-3">
        <label :for={{label, value} <- @options} class="flex items-center gap-2 cursor-pointer">
          <% is_checked = to_string(@value) == to_string(value) %>
          <div class="relative">
            <input
              type="radio"
              id={"#{@id}_#{value}"}
              name={@name}
              value={value}
              checked={is_checked}
              class="peer sr-only pearl-radio"
              {@rest}
            />
            <div class="h-6.5 w-6.5 rounded-full border-2 border-gray-300 bg-[#EFEFED] peer-checked:border-primary peer-checked:border-3 peer-checked:bg-[#EFEFED] flex items-center justify-center">
            </div>
            <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-3.5 w-3.5 rounded-full bg-primary opacity-0 peer-checked:opacity-100 transition-opacity duration-50 pointer-events-none">
            </div>
          </div>
          <span class={"text-sm text-gray-900 #{@class}"}>{label}</span>
        </label>
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <.label for={@id} class={@label_class}>{@label}</.label>
      <div class="w-full">
        <select
          id={@id}
          name={@name}
          class={[
            input_class(@variant),
            @class
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
        <.error :for={msg <- @errors}>{msg}</.error>
      </div>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <.label for={@id} class={@label_class}>{@label}</.label>
      <div class="w-full">
        <textarea
          id={@id}
          name={@name}
          class={[
            input_class(@variant),
            "min-h-24",
            @class,
            input_border(@variant, @errors)
          ]}
          {@rest}
        ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
        <.error :for={msg <- @errors}>{msg}</.error>
      </div>
    </div>
    """
  end

  def input(%{type: "segmented-radio"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <div
        class={["inline-flex rounded-full border border-gray-300 bg-gray-50 p-1 mt-2", @class]}
        role="group"
      >
        <%= for {label, value} <- @options do %>
          <% is_checked = to_string(@value) == to_string(value) %>
          <label class={[
            "relative cursor-pointer px-4 py-2 text-sm text-primary font-medium transition-all rounded-full",
            if(is_checked, do: "bg-primary/10 shadow-sm", else: " hover:text-primary/40")
          ]}>
            <input
              type="radio"
              id={"#{@id}_#{value}"}
              name={@name}
              value={value}
              checked={is_checked}
              class="sr-only"
              {@rest}
            />
            {label}
          </label>
        <% end %>
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@wrapper_class}>
      <.label for={@id} class={@label_class}>{@label}</.label>
      <div class="w-full">
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            input_class(@variant),
            @class,
            input_border(@variant, @errors)
          ]}
          {@rest}
        />
        <.error :for={msg <- @errors}>{msg}</.error>
      </div>
    </div>
    """
  end

  defp input_class(:default) do
    "mt-2 block w-full rounded-lg text-dark focus:ring-0 sm:text-sm sm:leading-6 bg-surface border-0"
  end

  defp input_class(:flushed) do
    "block w-full px-0 py-2 border-0 border-b border-dark-muted/30 focus:border-primary focus:ring-0 bg-transparent text-dark placeholder-dark-muted/60 focus:outline-none transition-colors sm:text-sm [&>option]:bg-white [&>option]:text-dark [&>option:checked]:bg-primary [&>option:checked]:text-white [&>option:hover]:bg-primary [&>option:hover]:text-white"
  end

  defp input_border(:default, errors) do
    if errors == [] do
      "border-transparent focus:border-primary"
    else
      "border-danger-400 focus:border-danger-400"
    end
  end

  defp input_border(:flushed, errors) do
    if errors == [] do
      ""
    else
      "border-danger-500 focus:border-danger-500 text-danger-500 placeholder-danger-300"
    end
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={"block text-sm font-semibold leading-6 dark:text-white #{@class}"}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil
  attr :title_class, :string, default: ""

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[
      @actions != [] &&
        "flex items-left sm:items-center justify-between gap-2 sm:gap-6 flex-row",
      @class
    ]}>
      <div class="flex flex-col justify-center">
        <h1 class={"font-semibold leading-8 #{@title_class}"}>
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500">{item.title}</dt>
          <dd class="text-zinc-700">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-dark hover:text-darkShade/80 dark:text-light dark:hover:text-lightShade/80"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc """
  Renders an icon.
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} {@rest} />
    """
  end

  def icon(%{name: "fa-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} {@rest} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(PearlWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PearlWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
