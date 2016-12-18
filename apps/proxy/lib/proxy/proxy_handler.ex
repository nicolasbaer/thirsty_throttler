defmodule Proxy.ProxyHandler do

  def init(req, state) do
    handle(req, state)
  end

  def serve_proxy(request, state) do
     req = :cowboy_req.reply(
      200,
      [ {"content-type", "text/html"} ],
      build_body(request),
      request
    )
    {:ok, req, state}
  end

  def serve_error(request, state) do
      req = :cowboy_req.reply(
      500,
      [ {"content-type", "text/html"} ],
      "not good..",
      request
    )
    {:ok, req, state}
  end

  def handle(request, state) do

    case Throttler.Random.throttle nil do
      true -> serve_error request, state
      false -> serve_proxy request, state
    end
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

  def sess_id(h) do 
    case h do 
      {"sessionid", _} -> true 
      _ -> false 
    end
  end  

  def build_body(request) do
    #headers = :cowboy_req.headers(request) 
    #sessionId = Enum.find(headers, nil, &sess_id/1) |> elem(1)
    path = :cowboy_req.path(request) 

    HTTPoison.start
    url = "localhost:8081" <> path
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end

  def dl_headers(request) do
    headers = :cowboy_req.headers(request)
    Enum.map(headers, fn item -> "<dt>#{elem(item, 0)}</dt><dd>#{elem(item, 1)}</dd>" end)
  end

end
