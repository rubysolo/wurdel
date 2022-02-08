defmodule WurdelWeb.GameLive do
  use Surface.LiveView

  alias Wurdel.Game

  def mount(_params, _context, socket) do
    socket =
      socket
      |> assign(:game, Game.new_game())
      |> assign(:error, "")

    {:ok, socket}
  end

  @alphabet String.graphemes("abcdefghijklmnopqrstuvwxyz")

  # submit current guess
  def handle_event(
        "handle-key",
        %{"key" => "Enter"},
        %{assigns: %{game: %{current_guess: current_guess} = game}} = socket
      )
      when length(current_guess) == 5 do

    socket =
      case Game.add_guess(game, Enum.join(current_guess)) do
        %Game{} = game ->
          assign(socket, :game, game)

        {:error, :invalid_guess} ->
          assign(socket, :error, "Invalid guess")
      end

    {:noreply, socket}
  end

  # remove letter from current guess
  def handle_event(
        "handle-key",
        %{"key" => "Backspace"},
        %{assigns: %{game: %{} = game}} = socket
      ) do
    game = Game.remove_letter(game)

    socket =
      socket
      |> assign(:game, game)
      |> assign(:error, "")

    {:noreply, socket}
  end

  # add letter to current guess
  def handle_event(
        "handle-key",
        %{"key" => letter},
        %{assigns: %{game: %{current_guess: current_guess} = game}} = socket
      )
      when letter in @alphabet and length(current_guess) < 5 do
    game = Game.add_letter(game, letter)

    {:noreply, assign(socket, :game, game)}
  end

  # no-op
  def handle_event("handle-key", %{"key" => _letter}, socket) do
    {:noreply, socket}
  end

  def render(%{game: %Game{} = game} = assigns) do
    ~F"""
    <div id="game" phx-window-keyup="handle-key" class="m-3">
      <.render_guess guess={guess} :for={guess <- Enum.reverse(game.guesses)} />
      <.render_guess guess={game.current_guess} />
      <.render_won game={game} />
      <.render_lost game={game} />
      <.render_error error={@error} />
      <.render_keyboard game={game} />
    </div>
    """
  end

  def render_guess(%{guess: letters} = assigns) when is_list(letters) do
    ~F"""
    <div class="w-[16.6rem] m-auto">
      <.render_letter letter={letter} status={nil} :for={letter <- letters} />
    </div>
    """
  end

  def render_guess(%{guess: %Game.Guess{word: word, letters: letters}} = assigns) do
    pairs =
      word
      |> String.graphemes()
      |> Enum.zip(letters)

    ~F"""
    <div class="w-[16.6rem] m-auto">
      <.render_letter letter={letter} status={status} :for={{letter, status} <- pairs} />
    </div>
    """
  end

  def render_letter(%{letter: letter, status: status} = assigns) do
    color =
      case status do
        :ok -> "bg-green-500"
        :wrong_position -> "bg-yellow-300"
        :no_match -> "bg-gray-500 text-white"
        _ -> "bg-gray-300"
      end

    ~F"""
    <div class={"mt-3 ml-3 first:ml-0 pt-2 w-10 h-10 text-center inline-block uppercase rounded " <> color}>{letter}</div>
    """
  end

  def render_won(%{game: %Game{status: :won}} = assigns) do
    ~F"""
    <div class="text-center">
    Congratulations, you guessed the word! 🎉
    </div>
    """
  end

  def render_won(assigns) do
    ~F{}
  end

  def render_lost(%{game: %Game{status: :lost}} = assigns) do
    ~F"""
    <div class="text-center">
    Sorry, better luck next time. 😞
    </div>
    """
  end

  def render_lost(assigns) do
    ~F{}
  end

  def render_error(%{error: error} = assigns) do
    ~F"""
    <div class="text-red-500 text-center">{error}</div>
    """
  end

  @top_row String.graphemes("qwertyuiop")
  @middle_row String.graphemes("asdfghjkl")
  @bottom_row String.graphemes("zxcvbnm")

  def render_keyboard(%{game: %Game{guesses: guesses}} = assigns) do
    rows = [@top_row, @middle_row, @bottom_row]

    guessed_letters =
      guesses
      |> Enum.flat_map(&String.graphemes(&1.word))
      |> MapSet.new()

    ~F"""
    <div class="p-3  bg-gray-100 fixed bottom-0 left-1/2 right-1/2 -mx-[50%] ">
      <div class="w-fit m-auto" :for={row <- rows}>
        <.render_key key={key} guessed={MapSet.member?(guessed_letters, key)} :for={key <- row} />
      </div>
    </div>
    """
  end

  def render_key(%{key: key, guessed: guessed} = assigns) do
    color =
      if guessed do
        "bg-gray-500 text-white"
      else
        "bg-gray-300"
      end

    ~F"""
    <div class={"mt-1 ml-1 first:ml-0 w-6 h-6 text-center inline-block uppercase rounded " <> color}>{key}</div>
    """
  end
end
