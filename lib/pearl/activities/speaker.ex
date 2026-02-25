defmodule Pearl.Activities.Speaker do
  @moduledoc """
  Speakers participate in the event's activities.
  """
  use Pearl.Schema
  import Bitwise

  alias Pearl.Activities

  @required_fields ~w(name company title)a
  @optional_fields ~w(biography highlighted accent_color)a
  @virtual_fields ~w(accent_color_hex)a

  @derive {
    Flop.Schema,
    filterable: [:name, :activity_date],
    sortable: [:name, :company],
    adapter_opts: [
      join_fields: [
        activity_date: [
          binding: :activities,
          field: :date,
          ecto_type: :date,
          path: [:activities, :date]
        ]
      ]
    ]
  }

  schema "speakers" do
    field :name, :string
    field :title, :string
    field :picture, Uploaders.Speaker.Type
    field :company, :string
    field :biography, :string
    field :highlighted, :boolean, default: false
    field :accent_color, :map, default: %{"r" => 129, "g" => 24, "b" => 36}
    field :accent_color_hex, :string, virtual: true

    embeds_one :socials, Activities.Speaker.Socials

    many_to_many :activities, Activities.Activity,
      join_through: "activities_speakers",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(speaker, attrs) do
    speaker
    |> cast(attrs, @required_fields ++ @optional_fields ++ @virtual_fields)
    |> cast_embed(:socials)
    |> validate_required(@required_fields)
    |> sync_accent_color()
  end

  defp sync_accent_color(changeset) do
    case get_change(changeset, :accent_color_hex) do
      "#" <> hex when byte_size(hex) == 6 ->
        case Integer.parse(hex, 16) do
          {int, ""} ->
            r = int >>> 16 &&& 0xFF
            g = int >>> 8 &&& 0xFF
            b = int &&& 0xFF
            put_change(changeset, :accent_color, %{"r" => r, "g" => g, "b" => b})

          _ ->
            changeset
        end

      _ ->
        case get_field(changeset, :accent_color) do
          %{"r" => r, "g" => g, "b" => b} ->
            hex = "##{Integer.to_string(r * 65536 + g * 256 + b + 0x1000000, 16) |> String.slice(1, 6)}"
            put_change(changeset, :accent_color_hex, hex)

          _ ->
            changeset
        end
    end
  end

  @doc false
  def picture_changeset(speaker, attrs) do
    speaker
    |> cast_attachments(attrs, [:picture])
  end
end

defmodule Pearl.Activities.Speaker.Socials do
  @moduledoc """
  Social media handles for speakers.
  """
  use Pearl.Schema

  embedded_schema do
    field :github, :string
    field :linkedin, :string
    field :website, :string
    field :x, :string
  end

  @doc false
  def changeset(socials, attrs) do
    socials
    |> cast(attrs, [:github, :linkedin, :website, :x])
    |> validate_url(:website)
    |> validate_github()
    |> validate_linkedin()
    |> validate_x()
  end

  def validate_github(changeset) do
    changeset
    |> validate_format(
      :github,
      ~r/^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,38}$/i,
      message: "not a valid github handle"
    )
  end

  def validate_linkedin(changeset) do
    changeset
    |> validate_length(:linkedin, min: 3, max: 100, message: "not a valid linkedin handle")
    |> validate_format(:linkedin, ~r/^\S+$/, message: "cannot contain spaces")
  end

  def validate_x(changeset) do
    changeset
    |> validate_format(
      :x,
      ~r/^[A-Za-z0-9_]{4,15}$/,
      message: "not a valid x handle"
    )
  end
end
