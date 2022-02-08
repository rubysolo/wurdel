defmodule Wurdel.DuJour do
  @moduledoc """
  Represent the word of the day as a GenServer
  """

  use GenServer

  @words File.read!("priv/words.txt")
         |> String.split("\n", trim: true)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.merge(opts, name: __MODULE__))
  end

  def init(:ok) do
    {:ok, %{}, {:continue, :load_wordlist}}
  end

  def handle_continue(:load_wordlist, state) do
    # make order consistent
    :rand.seed(:default, 42)
    word_list = Enum.shuffle(@words)

    {:noreply, Map.put(state, :words, word_list)}
  end

  def words do
    @words
  end

  def word do
    GenServer.call(__MODULE__, :word)
  end

  def handle_call(:word, _from, %{words: words} = state) do
    # get offset for today
    offset =
      Date.utc_today()
      |> Date.diff(~D[2022-01-01])
      |> rem(length(words))

    {:reply, Enum.at(words, offset), state}
  end
end
