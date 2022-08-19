

## JSON validation for Cowboy REST API, Mimic Celebrate Joi in Elixir


Thi is a Elixir Cowboy Plug module for incomming json validation.
Use schema definition, trying to mimic a (minimal) functionality of Celebrate Joi. 

Validate the presence of key, their data type and their stored value.

Has programers we want to write the minimal possible lines of code.
Bassically reduce all to a schema definition and then apply in our route.


**Schema:**
```elixir
photo_book_schema = [
                      qty: {:number, 1, 200},
                      hardcover: {:boolean},
                      colors: {:options, ["bw", "color", "sepia"]},
                      client_name: {:string, 6, 20},
                      client_phone: {:string, 8, 25, ~r/^[\d\-()\s]+$/}
                    ]
```                        

**Route:**

```elixir
plug(:match)
plug(Plug.RouterValidatorschema, on_error: &__MODULE__.on_error_fn/2)
plug(:dispatch)

post "/create/", private: %{validate: photo_book_schema} do
  status = Orders.create(conn.body_params)
  {:ok, str} = Jason.encode(%{status: status})
  send_resp(conn |> put_resp_content_type("application/json"), str)
end

def on_error_fn(conn, errors, status \\ 422) do
  IO.inspect(errors, label: "errors")
  {:ok, str} = Jason.encode(%{status: "fail", errors: errors})
  send_resp(conn |> put_resp_content_type("application/json"), str) |> halt()
end

```

For more complex validations is recommended to use Ecto.Changests https://hexdocs.pm/ecto/Ecto.Changeset.html

Full description in [Dev.to](https://dev.to/lionelmarco/json-validation-for-cowboy-rest-api-mimic-celebrate-joi-in-elixir-4l27)












