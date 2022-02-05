defmodule WurdelWeb.GameLive do
  use Surface.LiveView

  alias Wurdel.Game

  def mount(_params, _context, socket) do
    socket = assign(socket, :game, Game.new_game())
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
    game = Game.add_guess(game, Enum.join(current_guess))

    {:noreply, assign(socket, :game, game)}
  end

  # remove letter from current guess
  def handle_event(
        "handle-key",
        %{"key" => "Backspace"},
        %{assigns: %{game: %{} = game}} = socket
      ) do
    game = Game.remove_letter(game)

    {:noreply, assign(socket, :game, game)}
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
  def handle_event("handle-key", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  def render(%{game: %Game{} = game} = assigns) do
    ~F"""
    <div id="game" phx-window-keyup="handle-key" class="m-3">
      <.render_guess guess={guess} :for={guess <- Enum.reverse(game.guesses)} />
      <.render_guess guess={game.current_guess} />
      <.render_won game={game} />
      <.render_lost game={game} />
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
    Congratulations, you guessed the word! 🎉
    """
  end

  def render_won(assigns) do
    ~F{}
  end

  def render_lost(%{game: %Game{status: :lost}} = assigns) do
    ~F"""
    Sorry, better luck next time. 😞
    """
  end

  def render_lost(assigns) do
    ~F{}
  end
end