defmodule Wurdel.Game do
  @moduledoc """
  State for an individual game
  """
  use TypedStruct

  alias Wurdel.{DuJour, Game}

  @allowed_guesses ~w[priv/words.txt priv/allowed-guesses.txt]
                   |> Enum.flat_map(fn filename ->
                     filename
                     |> File.read!()
                     |> String.split("\n", trim: true)
                   end)

  typedstruct enforce: true do
    @type status :: :playing | :won | :lost

    field(:word, String.t())
    field(:current_guess, list(String.t()))
    field(:guesses, list(Guess.t()))
    field(:start, DateTime.t())
    field(:status, status())
  end

  typedstruct module: Guess, enforce: true do
    @type letter :: :ok | :wrong_position | :no_match

    field(:word, String.t())
    field(:letters, list(letter()))
    field(:time, DateTime.t())
  end

  def new_game do
    %Game{
      word: DuJour.word(),
      current_guess: [],
      guesses: [],
      start: DateTime.utc_now(),
      status: :playing
    }
  end

  def add_letter(%Game{current_guess: current_guess} = game, letter) do
    %{game | current_guess: current_guess ++ [letter]}
  end

  def remove_letter(%Game{current_guess: current_guess} = game) when length(current_guess) > 0 do
    current_guess =
      current_guess
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()

    %{game | current_guess: current_guess}
  end

  def remove_letter(game), do: game

  def add_guess(%Game{} = game, guess) when guess in @allowed_guesses do
    add_allowed_guess(game, guess)
  end

  def add_guess(_game, _guess) do
    {:error, :invalid_guess}
  end

  def add_allowed_guess(%Game{status: :won} = game, _guess), do: game
  def add_allowed_guess(%Game{status: :lost} = game, _guess), do: game

  def add_allowed_guess(%Game{word: word, guesses: guesses} = game, word) when is_binary(word) do
    %{game | status: :won, current_guess: [], guesses: [new_guess(word, word) | guesses]}
  end

  def add_allowed_guess(%Game{word: word, guesses: guesses} = game, guess) when is_binary(word) do
    next_status = if length(guesses) < 5, do: :playing, else: :lost
    %{game | status: next_status, current_guess: [], guesses: [new_guess(word, guess) | guesses]}
  end

  defp new_guess(correct_word, guess) do
    correct_letters = String.graphemes(correct_word)
    correct_letter_set = MapSet.new(correct_letters)
    guess_letters = String.graphemes(guess)

    letters =
      correct_letters
      |> Enum.zip(guess_letters)
      |> Enum.map(fn {correct_letter, guess_letter} ->
        cond do
          correct_letter == guess_letter -> :ok
          MapSet.member?(correct_letter_set, guess_letter) -> :wrong_position
          :otherwise -> :no_match
        end
      end)

    %Guess{word: guess, letters: letters, time: DateTime.utc_now()}
  end
end
