defmodule CiStatus.Web do
  alias CiStatus.Db.Schema, as: Schema
  alias CiStatus.Db.Repo, as: Repo

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

  defp route("GET", [type, "packages", name, "versions", version, "badge"], _conn) do
    IO.puts "Get '#{type}' badge for '#{name}' in version '#{version}'"
    case Repo.get_by(Schema.Status, type: type, name: name, version: version) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema.Status{badge_text: badge_text, badge_color: badge_color} ->
        badge_link = "https://img.shields.io/badge/" <> type <> "-" <> URI.encode(badge_text) <> "-" <> badge_color <> ".svg"
        {:redirect, badge_link}
    end
  end

  defp route("GET", [type, "packages", name, "versions", version, "link"], _conn) do
    IO.puts "Get '#{type}' link for '#{name}' in version '#{version}'"
    case Repo.get_by(Schema.Status, type: type, name: name, version: version) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema.Status{link: link} ->
        {:redirect, link}
    end
  end

  defp route("PUT", [type, "packages", name, "versions", version], conn) do
    {:ok, binbody, _} =
      conn |> Plug.Conn.read_body
    body = Poison.decode!(binbody)
    IO.puts "Put '#{type}' status for '#{name}, version: #{version}, body: #{binbody}'"
    link = body["link"]
    badge = body["badge"]
    badge_text = badge["text"]
    badge_color = badge["color"]
    result = case Repo.get_by(Schema.Status, type: type, name: name, version: version) do
      nil  -> %Schema.Status{type: type, name: name, version: version}
      status -> status
    end
    |> Schema.Status.changeset(%{link: link, badge_text: badge_text, badge_color: badge_color})
    |> Repo.insert_or_update
    case result do
      {:ok, _} ->
        {:ok, "Status updated"}
      {:error, changeset} ->
        if not changeset.valid? do
          {:error, 400, changeset.errors |> inspect}
        else
          {:error, 500, "Internal Server Error"}
        end
    end
  end

  defp route(_method, _path, _conn) do
    {:error, 404, "Not Found"}
  end
end
