defmodule Wurdel.DuJour do
  @moduledoc """
  Represent the word of the day as a GenServer
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.merge(opts, name: __MODULE__))
  end

  def init(:ok) do
    {:ok, %{}, {:continue, :load_wordlist}}
  end

  def handle_continue(:load_wordlist, state) do
    :rand.seed(:default, 42) # make repeatable
    words =
      File.stream!("priv/words.txt")
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()
      |> Enum.shuffle()

    {:noreply, Map.put(state, :words, words)}
  end

  def word do
    GenServer.call(__MODULE__, :word)
  end

  def handle_call(:word, _from, %{words: words} = state) do
    # get offset for today
    offset =
      Date.utc_today()
      |>  Date.diff(~D[2022-01-01])
      |> rem(length(words))

    {:reply, Enum.at(words, offset), state}
  end
end
