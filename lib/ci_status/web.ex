defmodule CiStatus.Web do
  alias CiStatus.Schema, as: Schema
  alias CiStatus.Repo, as: Repo

  def init(opts) do
    IO.puts "Starting up CiStatus..."
    opts
  end

  def call(conn, _opts) do
    method = conn.method
    path = conn.path_info
    IO.puts "\n* HTTP request: #{method} #{conn.request_path}"
    {status, headers, body} =
      case route(method, path, conn) do
        {:ok, body} ->
          {200, [], body}
        {:redirect, link} ->
          {301, [{"location", link}], "Redirect to #{link}"}
        {:error, status, body} ->
          {status, [], body}
      end
    IO.puts("\n* HTTP response status: #{status}, body: #{body}")
    conn
      |> Plug.Conn.merge_resp_headers(headers)
      |> Plug.Conn.send_resp(status, body)
  end

  defp route("GET", [type, "packages", name, "badge"], _conn) do
    IO.puts "Get '#{type}' badge for '#{name}'"
    case Repo.get_by(Schema, type: type, name: name) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema{badge_text: badge_text, badge_color: badge_color} ->
        badge_link = "https://img.shields.io/badge/" <> type <> "-" <> URI.encode(badge_text) <> "-" <> badge_color <> ".svg"
        {:redirect, badge_link}
    end
  end

  defp route("GET", [type, "packages", name, "link"], _conn) do
    IO.puts "Get '#{type}' link for '#{name}'"
    case Repo.get_by(Schema, type: type, name: name) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema{link: link} ->
        {:redirect, link}
    end
  end

  defp route("PUT", [type, "packages", name], conn) do
    {:ok, binbody, _} =
      conn |> Plug.Conn.read_body
    body = Poison.decode!(binbody)
    IO.puts "Put '#{type}' status for '#{name}, body: #{binbody}'"
    link = body["link"]
    badge = body["badge"]
    badge_text = badge["text"]
    badge_color = badge["color"]
    status = %Schema{type: type, name: name, link: link, badge_text: badge_text, badge_color: badge_color}
    # TODO: change to on_conflict: :replace_all when PSQL is used
    Repo.insert(status, on_conflict: :nothing)
    {:ok, "Status updated"}
  end

  defp route(_method, _path, _conn) do
    {:error, 404, "Not Found"}
  end
end
