defmodule Plug.RouterValidatorSchemma do


  @doc """
  Validation start when `validate` key is in the field `conn.private`

  Reduce the  `schema`,  If all validations are successful returns an empty map.
  Otherwise when validation fail, call the given `on_error` callback with a list of the collected errors.

  The errors list have the shape `[ %{"key1"=> "error"}, %{"key2"=> "error"}]`
  """



  def init(opts), do: opts
  #alias Plug.Conn
    def call(conn, opts) do
    case conn.private[:validate] do
      nil -> conn
      schemma -> validate_schemma(conn,schemma, opts[:on_error])
    end
  end

 # -----------------------------------------
 # Validate  Schemma
 # -----------------------------------------

  defp validate_schemma(conn, schemma, on_error) do

    # errors is a list of maps = [ %{"key1"=> "error"}, %{"key2"=> "error"}]
    errors = Enum.reduce(schemma, [], validate_key(conn.body_params))
    if Enum.empty?(errors) do
      conn
    else
      on_error.(conn,  %{ errors: errors})
    end
  end



  defp validate_key(data) do
    # IO.inspect(data, label: "validate_key data")
    fn ({key,test}, errors) ->
      skey=Atom.to_string(key)
      cond do
       not Map.has_key?(data, skey) -> [ %{ key =>"missing key"}  | errors ]
       is_nil(data[skey]) -> [ %{ key => "value is nil"}  | errors ]   # or just return errors if value can accept nil
       true ->case is_t(test, data[skey]) do
                      :ok -> errors
                      {:invalid, reason} -> [ %{ key => reason}  | errors ]
              end
      end
    end
  end


 # evaluate, test, check
 defp is_t({:number}, value) do
  if not is_number(value) do
    {:invalid, "not is number"}
  else
    :ok
  end
end

defp is_t({:boolean}, value) do
  if not is_boolean(value) do
    {:invalid, "not is boolean"}
  else
    :ok
  end
end

defp is_t({:string}, value) do
  if is_bitstring(value) do
    :ok
  else
    {:invalid, "not is string"}
  end
end

defp is_t({:number, vmin, vmax}, value) do
  cond do
    not is_number(value) -> {:invalid, "not is number"}
    value <= vmin -> {:invalid, "min value"}
    value > vmax -> {:invalid, "max value"}
    true -> :ok
  end
end

defp is_t({:string, lmin, lmax}, value) do
  cond do
    not is_bitstring(value) -> {:invalid, "not is string"}
    String.length(value) <= lmin -> {:invalid, "min length"}
    String.length(value) > lmax -> {:invalid, "max length"}
    true -> :ok
  end
end

defp is_t({:string, lmin, lmax, reg}, value) do
  cond do
    not is_bitstring(value) -> {:invalid, "not is string"}
    String.length(value) <= lmin -> {:invalid, "min length"}
    String.length(value) > lmax -> {:invalid, "max length"}
    not Regex.match?(reg, value) -> {:invalid, "regex not match"}
    true -> :ok
  end
end

defp is_t({:options, alloweds}, value) do
  cond do
    value not in alloweds -> {:invalid, "not allowed"}
    true -> :ok
  end
end

# ---------------------------
# Final match : This code will never be reached
# ---------------------------
defp is_t(_value,_test) do
  {:invalid, "test match fail"}
end
# ---------------------------

end
