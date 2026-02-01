defmodule Pearl.Billing do
  @moduledoc """
  The Billing context.
  """

  use Pearl.Context

  alias Pearl.Accounts
  alias Pearl.Billing.Payment
  alias Pearl.Tickets

  @pubsub Pearl.PubSub

  def start_payment(:mbway, ticket_id, order_data) do
    ticket = Tickets.get_ticket!(ticket_id)
    ticket_type = ticket.ticket_type
    user = Accounts.get_user!(ticket.user_id)
    checkout_info = get_checkout_information(ticket_type)

    with :ok <- validate_midas_config(ticket_type) do
      case Req.post(midas_api_url() <> "/orders",
             headers: [{"authorization", "Bearer " <> midas_api_key()}],
             json: %{
               order: %{
                 lines: [
                   %{
                     product_id: ticket_type.product_key,
                     quantity: checkout_info.quantity,
                     discount: 0
                   }
                 ],
                 customer_email: user.email,
                 customer_name: user.name,
                 customer_tax_id:
                   if order_data["tax_id"] == "" do
                     nil
                   else
                     order_data["tax_id"]
                   end,
                 payment: %{
                   method: "mbway",
                   phone_number: order_data["phone_number"]
                 },
                 message: "CeSIUM - ENEI 2026 Tickets",
                 extra_fields: %{ticket_id: ticket_id}
               }
             }
           ) do
        {:ok, %Req.Response{status: 201, body: body}} ->
          {:ok,
           create_payment(%{
             amount: checkout_info.total,
             order_id: body["id"],
             status: :pending,
             ticket_id: ticket_id
           })}

        {:ok, %Req.Response{status: status, body: body}} ->
          {:error, %{status: status, body: body}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp validate_midas_config(ticket_type) do
    cond do
      not is_binary(midas_api_url()) ->
        {:error, :missing_midas_api_url}

      is_nil(ticket_type.product_key) ->
        {:error, :missing_ticket_product_id}

      not is_binary(midas_api_key()) or midas_api_key() == "" ->
        {:error, :missing_midas_api_key}

      true ->
        :ok
    end
  end

  def get_checkout_information(ticket_type) do
    %{
      quantity: 1,
      per_unit: ticket_type.price,
      total: ticket_type.price
    }
  end

  defp midas_api_url do
    Application.fetch_env!(:pearl, Pearl.Billing)[:midas_api_url]
  end

  defp midas_api_key do
    Application.fetch_env!(:pearl, Pearl.Billing)[:midas_api_key]
  end

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments do
    Repo.all(Payment)
  end

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get_payment!(123)
      %Payment{}

      iex> get_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Gets a single payment by ticket_id

  ## Examples

      iex> get_payment_by_ticket("some ticket_id")
      %Payment{}

      iex> get_payment_by_ticket_id("nonexistent ticket_id")
      nil

  """
  def get_payment_by_ticket(ticket_id) do
    Payment |> Repo.get_by(ticket_id: ticket_id)
  end

  @doc """
  Gets a single payment by order_id.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get_payment_by_order_id!("some order_id")
      %Payment{}

      iex> get_payment_by_order_id!("nonexistent order_id")
      ** (Ecto.NoResultsError)

  """
  def get_payment_by_order_id!(order_id) do
    Payment
    |> preload(:ticket)
    |> Repo.get_by!(order_id: order_id)
  end

  @doc """
  Gets a single payment by order_id.

  ## Examples

      iex> get_payment_by_order_id("some order_id")
      %Payment{}

      iex> get_payment_by_order_id("nonexistent order_id")
      nil

  """
  def get_payment_by_order_id(order_id) do
    Repo.get_by(Payment, order_id: order_id)
  end

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(attrs) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment.

  ## Examples

      iex> update_payment(payment, %{field: new_value})
      {:ok, %Payment{}}

      iex> update_payment(payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment.

  ## Examples

      iex> delete_payment(payment)
      {:ok, %Payment{}}

      iex> delete_payment(payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment changes.

  ## Examples

      iex> change_payment(payment)
      %Ecto.Changeset{data: %Payment{}}

  """
  def change_payment(%Payment{} = payment, attrs \\ %{}) do
    Payment.changeset(payment, attrs)
  end

  @doc """
  Marks a payment as completed.

  ## Examples

      iex> mark_payment_completed(order_id)
      {:ok, %Payment{}}

      iex> mark_payment_completed(invalid_order_id)
      {:error, %Ecto.Changeset{}}

  """
  def mark_payment_completed(order_id) do
    payment = get_payment_by_order_id!(order_id)

    Tickets.mark_ticket_as_paid(payment.ticket)

    update_payment(payment, %{status: :completed})
    |> broadcast_payment_order_update()
  end

  def subscribe_to_payment_order_updates(order_id) do
    Phoenix.PubSub.subscribe(@pubsub, "payment_order:#{order_id}")
  end

  defp broadcast_payment_order_update(result) do
    case result do
      {:ok, %Payment{} = payment} ->
        Phoenix.PubSub.broadcast(
          @pubsub,
          "payment_order:#{payment.order_id}",
          {:payment_order_updated, payment}
        )

        result

      {:error, _reason} ->
        result
    end
  end
end
