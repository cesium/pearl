defmodule PearlWeb.MidasController do
  use PearlWeb, :controller
  alias Pearl.Billing

  @doc """
  Handle Midas payment webhook.
  """
  def handle_webhook(
        conn,
        %{"pearl_api_key" => pearl_api_key, "order_id" => order_id, "status" => status} = _params
      ) do
    if pearl_api_key == Application.fetch_env!(:pearl, Pearl.Billing)[:pearl_api_key] do
      payment = Billing.get_payment_by_order_id(order_id)

      if payment do
        case status do
          :completed -> handle_completed_payment(conn, payment, order_id)
          _ -> handle_cancelled_payment(conn, payment, order_id)
        end
      end
    else
      send_resp(conn, 403, "invalid api key")
    end
  end

  defp handle_completed_payment(conn, payment, order_id) do
    if payment.status != :completed do
      case Billing.mark_payment_completed(order_id) do
        {:error, reason} ->
          send_resp(conn, 400, "error: #{inspect(reason)}")

        _ ->
          send_resp(conn, 200, "success")
      end
    else
      send_resp(conn, 404, "payment not found")
    end
  end

  defp handle_cancelled_payment(conn, payment, order_id) do
    if payment.status != :completed do
      case Billing.mark_payment_cancelled(order_id) do
        {:error, reason} ->
          send_resp(conn, 400, "error: #{inspect(reason)}")

        _ ->
          send_resp(conn, 200, "success")
      end
    else
      send_resp(conn, 404, "payment not found")
    end
  end
end
