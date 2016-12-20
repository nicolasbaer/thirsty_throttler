defmodule TCPProxy do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: TCPProxy.TaskSupervisor]]),
      worker(Task, [TCPProxy, :accept, [8082]])
    ]

    opts = [strategy: :one_for_one, name: TCPProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"

    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, remote} = :gen_tcp.connect('127.0.0.1', 8081, [:binary, packet: 0, active: false])
    {:ok, pid_client} = Task.Supervisor.start_child(TCPProxy.TaskSupervisor, fn -> serve(client, remote) end)
    {:ok, pid_remote} = Task.Supervisor.start_child(TCPProxy.TaskSupervisor, fn -> serve(remote, client) end)
    :ok = :gen_tcp.controlling_process(client, pid_client)
    :ok = :gen_tcp.controlling_process(remote, pid_remote)
    loop_acceptor(socket)
  end

  def serve(socket1, socket2) do
    case read(socket1) |> filter |> send_packet(socket2) do
      :ok     -> serve(socket1, socket2)
      :closed -> Logger.info "client and remote connection closed."
    end
  end

  def read(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data}       ->  data
      {:error, :closed} ->  :gen_tcp.close(client)
                            :closed
    end
  end

  def filter(data) do
    case data do
      _       ->  {:ok, packet, rest} = :erlang.decode_packet(:http, data, [])
                  case packet do
                    {:http_request, _, _, _}  ->  Logger.info "possible filter on http request #{inspect packet} #{inspect rest}"
                                                  data
                    {:http_response, _, _, _} ->  Logger.info "possible cookie injection on http response #{inspect packet} #{inspect rest}"
                                                  data
                    _ -> data
                  end
      :closed -> data
    end
  end

  def send_packet(data, remote) do
    case data do
      _       ->  :gen_tcp.send(remote, data)
      :closed ->  :gen_tcp.close(remote)
                  :closed
    end
  end

end
