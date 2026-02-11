defmodule Pearl.Event.Faq do
  @moduledoc """
  A frequently asked question.
  """
  use Pearl.Schema

  @required_fields ~w(topic answer question)a
  @optional_fields ~w(is_article)a

  schema "faqs" do
    field :topic, :string
    field :question, :string
    field :answer, :string
    field :is_article, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(faq, attrs) do
    faq
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
