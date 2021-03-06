defmodule CiStatus.Web do
  alias CiStatus.Db.Schema, as: Schema
  alias CiStatus.Db.Repo, as: Repo

  @secret Application.get_env(:ci_status, :secret)
  @shields_url Application.get_env(:ci_status, :shields_url)

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
        {:ok, headers, body} ->
          {200, headers, body}
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

  defp route("GET", ["packages", name, "versions", version, type, "badge"], _conn) do
    IO.puts "Get '#{type}' badge for '#{name}' in version '#{version}'"
    case Repo.get_by(Schema.Status, type: type, name: name, version: version) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema.Status{badge_text: badge_text, badge_color: badge_color} ->
        badge_link = @shields_url <> "/badge/" <> type <> "-" <> URI.encode(badge_text) <> "-" <> badge_color <> ".svg"
        case HTTPoison.get(badge_link) do
          {:ok, %HTTPoison.Response{status_code: 200, body: badge}} ->
            headers = [{"content-type", "image/svg+xml"}]
            {:ok, headers, badge}
          {:ok, %HTTPoison.Response{status_code: status_code, body: rsp_body}} ->
            {:error, status_code, rsp_body}
        end
    end
  end

  defp route("GET", ["packages", name, "versions", version, type, "link"], _conn) do
    IO.puts "Get '#{type}' link for '#{name}' in version '#{version}'"
    case Repo.get_by(Schema.Status, type: type, name: name, version: version) do
      nil ->
        {:error, 404, "Status not Found"}
      %Schema.Status{link: link} ->
        {:redirect, link}
    end
  end

  defp route("PUT", ["packages", name, "versions", version, type], conn) do
    if is_authenticated?(conn) do
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
          {:ok, [], "Status updated"}
        {:error, changeset} ->
          if not changeset.valid? do
            {:error, 400, changeset.errors |> inspect}
          else
            {:error, 500, "Internal Server Error"}
          end
      end
    else
      {:error, 401, "Unauthorized"}
    end
  end

  defp route(_method, _path, _conn) do
    {:error, 404, "Not Found"}
  end

  defp is_authenticated?(conn) do
    :proplists.get_value("x-ci-status-secret", conn.req_headers) == @secret
  end
end
