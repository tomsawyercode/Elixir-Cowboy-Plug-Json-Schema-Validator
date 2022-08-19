defmodule ValidatorTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias MyApp.Router

  test "Test Invalid" do
    json = %{
      qty: "10",
      hardcover: 0,
      colors: "red",
      firstname: "dem",
      phone: "(555)123-456*/-"
    }

    conn = conn(:post, "/create", json) |> put_req_header("content-type", "application/json")
    # Call the route
    conn = Router.call(conn, [])
    IO.inspect(conn.status, label: "status:")
    IO.inspect(conn.resp_body, label: "resp_body:")
    assert conn.status == 422
  end

  test "Test Valid" do
    json = %{
      qty: 10,
      hardcover: true,
      colors: "sepia",
      firstname: "demonds",
      phone: "(555)123-456"
    }

    conn = conn(:post, "/create", json) |> put_req_header("content-type", "application/json")
    # Call the route
    conn = Router.call(conn, [])
    IO.inspect(conn.status, label: "status")
    IO.inspect(conn.resp_body, label: "resp_body")
    assert conn.status == 200
  end
end

end
