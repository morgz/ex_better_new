defmodule ExBetterNew do
  @moduledoc """
  Documentation for `ExBetter`.
  """

  @doc """
  The general flow is:
  1. Get Times
  2. Get a slot
  3. Add slot to cart
  4. Checkout cart

  ## Examples

      iex> ExBetterNew.hello()
      :world

  """
  require Logger

  import ExBetterNew.Client, only: [request: 2]

  @default_user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15"
  @success_codes 200..299

  def client(url, token, opts \\ [])
  def client(:production, token, opts), do: client("https://better-admin.org.uk/api/", token, opts)
  def client(base_url, token, opts) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, Keyword.get(opts, :headers, [])},
      {Tesla.Middleware.Headers,
      [
        {"User-Agent", @default_user_agent},
        {"Origin", "https://bookings.better.org.uk"},
        {"Accept-Language", "en-GB;q=1.0"}
      ] ++ case token do # Maybe add the token if it's provided
        nil -> []
        "" -> []
        token -> [{"Authorization", "Bearer " <> token }]
      end
      }
    ]
    Tesla.client(middleware)
  end

  # client = ExBetterNew.client(:production, "token")
  # client |> ExBetterNew.current_user
  def current_user(client) do
    url = "auth/user"

    case request(client, method: :get, url: url) do
      {:ok, %Tesla.Env{status: status, body: body, url: url, method: method}}
      when status in @success_codes ->
        {:ok, body, [{:url, url}, {:status, status}, {:method, method}]}

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = other ->
        other
    end
  end

  def bookings(client, opts \\ []) do
    url = "my-account/bookings"

    case request(client, method: :get, url: url, query: opts) do
      {:ok, %Tesla.Env{status: status, body: body, url: url, method: method}}
      when status in @success_codes ->
        {:ok, body, [{:url, url}, {:status, status}, {:method, method}]}

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = other ->
        other
    end
  end

  #
  # Need to do categories
  #

  #
  # Session List
  #

  # client = ExBetterNew.client(:production, "token")
  # client |> ExBetterNew.times("queens-diamond-jubilee-centre", "swim-for-fitness", "2021-05-29")
  def times(
    client,
    venue_slug,
    category_slug,
    date,
    opts \\ []
  ) do

      url = "activities/venue"
      |> append_path_parameter(venue_slug)
      |> append_path_parameter("activity")
      |> append_path_parameter(category_slug)
      |> append_path_parameter("times?date=#{date}")

      case request(
        client,
        method: :get,
        url: url
      ) do
        {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
        when status in @success_codes ->
          {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
        {:ok, %Tesla.Env{body: body}} ->
          {:error, body}
        {:error, _} = other ->
          other
      end
    end

    #
    # Slots. Functions like a show action on Session
    #
    # client = ExBetterNew.client(:production, "token")
    # client |> ExBetterNew.slots("queens-diamond-jubilee-centre", "swim-for-fitness", "2021-05-29", "12:30", "13:20")

    def slots(
      client,
      venue_slug,
      category_slug,
      date,
      start_time,
      end_time,
      opts \\ []
    ) do

        url = "activities/venue"
        |> append_path_parameter(venue_slug)
        |> append_path_parameter("activity")
        |> append_path_parameter(category_slug)
        |> append_path_parameter("slots")

        # ====== Query Params ======
        query = [
          date: date,
          start_time: start_time,
          end_time: end_time,
        ]

        Logger.debug("Slots: #{url}")

        case request(
          client,
          method: :get,
          url: url,
          query: query
        ) do
          {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
          when status in @success_codes ->
            {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
          {:ok, %Tesla.Env{body: body} = t} ->
            Logger.debug(inspect t)
            {:error, body}
          {:error, _} = other ->
            other
        end
      end

  # this is deliberately simplistic for now
  # can explore the other params at a later date

  # client |> ExBetterNew.add_to_cart("303548")
  def add_to_cart(client, slot_id) do
    url = "activities/cart/add"

    body = %{
      items: [
        %{
          id: slot_id,
          type: "activity"
        }
      ]
    }

    case request(
      client,
      method: :post,
      url: url,
      body: body
    ) do
      {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
      when status in @success_codes ->
        {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}
      {:error, _} = other ->
        other
    end
  end

  # client |> ExBetterNew.pay()
  def pay(client) do
    url = "activities/cart/pay"

    case request(
      client,
      method: :post,
      url: url,
      body: nil
    ) do
      {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
      when status in @success_codes ->
        {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}
      {:error, _} = other ->
        other
    end
  end

  # client |> ExBetterNew.cancel_booking("366344")
  def cancel_booking(client, booking_id) do
    url =
      "activities/bookings"
      |> append_path_parameter(booking_id)

      case request(
        client,
        method: :delete,
        url: url,
        body: nil,
        query: [source: :my_account]
      ) do
        {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
        when status in @success_codes ->
          {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
        {:ok, %Tesla.Env{body: body}} ->
          {:error, body}
        {:error, _} = other ->
          other
      end
  end

  def append_path_parameter(url, nil), do: url

  def append_path_parameter(url, param) do
    url <> "/#{param}"
  end

end
