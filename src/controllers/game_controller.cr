class GameController < ApplicationController
  CONFIRM_ACTION = "confirm"

  before_action do
    only [:show, :new, :create, :update, :destroy] { redirect_signed_out_user }
  end

  def show
    if game = Game.find(params[:id])
      show_game_confirmation = false

      if player = current_player
        show_game_confirmation = Game::CanBeConfirmedByPlayer.new(
          game: game,
          player: player,
          include_admin: false
        ).call
      end

      league = game.league!
      winner_rating = game.winner.rating_for(league)
      loser_rating = game.loser.rating_for(league)

      rating_delta = game.rating_delta || Rating::DetermineDelta.new(
        winner_rating: winner_rating,
        loser_rating: loser_rating,
        league: game.league!
      ).call

      if !game.confirmed?
        read_game_logged_notification(game)
      end

      render("show.slang")
    else
      flash["warning"] = "Can't find game"
      redirect_to "/leagues/#{params[:league_id]}"
    end
  end

  def new
    game = Game.build
    league = League.find(params[:league_id])
    player_id_preselect = nil

    if league
      if tournament = Tournament.for_league(league).order(created_at: :desc).first
        if tournament.in_progress?
          current_player_id = current_player.not_nil!.id
          next_tournament_match = tournament.matches_query.where { (_winner_id == nil) & g((_player_a_id == current_player_id) | (_player_b_id == current_player_id)) }.order(level: :asc).limit(1).first

          player_id_preselect = [next_tournament_match.try(&.player_a_id), next_tournament_match.try(&.player_b_id)].reject { |player_id| player_id == current_player_id }.first
        end
      end

      other_players = available_opponents(league)

      if other_players.empty?
        flash["warning"] = "There are no other players to log against"
        redirect_to "/leagues/#{league.id}"
      else
        render("new.slang")
      end
    else
      flash["danger"] = "Can't find league"
      redirect_to "/leagues"
    end
  end

  def create
    player = current_player.not_nil!
    league = League.find(params[:league_id])
    other_player = Player.find(params["opponent-id"])

    unless league
      flash["danger"] = "Can't find league"
      redirect_to("/leagues"); return
    end

    unless other_player
      flash["danger"] = "Can't find opponent"
      other_players = available_opponents(league)
      player_id_preselect = nil
      render("new.slang"); return
    end

    winner, loser = params[:status] == "won" ? [player, other_player] : [other_player, player]

    game_logger = League::LogGame.new(
      winner: winner,
      loser: loser,
      league: league,
      logger: player
    )

    if game_logger.call
      game = game_logger.game

      flash["success"] = "Game logged"
      redirect_to "/leagues/#{league.id}/games/#{game.id}"
    else
      flash["danger"] = game_logger.errors.to_s
      other_players = available_opponents(league)
      player_id_preselect = nil

      render("new.slang")
    end
  end

  def update
    action = params[:action]
    game = Game.find(params[:game_id])

    unless game
      flash["danger"] = "Can't find game"

      if league = League.find(params[:league_id])
        redirect_to("/leagues/#{league.id}"); return
      else
        redirect_to("/leagues"); return
      end
    end

    case action
    when CONFIRM_ACTION
      confirming_player = current_player.not_nil!
      game_confirmation_service = Game::Confirm.new(
        game: game,
        confirming_player: confirming_player
      )

      if game_confirmation_service.call
        flash["success"] = "Confirmed game"
        read_game_logged_notification(game)
        redirect_to("/leagues/#{game.league_id}/games/#{game.id}"); return
      else
        flash["danger"] = game_confirmation_service.errors.join(", ")
        redirect_to("/leagues/#{game.league_id}/games/#{game.id}"); return
      end
    else
      flash["danger"] = "Unknown update action"
      redirect_to("/leagues/#{game.league_id}/games/#{game.id}"); return
    end
  end

  def quick_confirm
    if participation = Participation.where { _confirmation_code == params[:confirmation_code] }.first
      game = participation.game!
      player = participation.player!

      if game.confirmed?
        flash[:warning] = I18n.translate("game.already_confirmed")
        redirect_to "/leagues/#{game.league_id}/games/#{game.id}"
      else
        game_confirmation_service = Game::Confirm.new(
          game: game,
          confirming_player: player
        )

        if game_confirmation_service.call
          read_game_logged_notification(game, player)

          flash["success"] = "Confirmed game"
          redirect_to "/leagues/#{game.league_id}/games/#{game.id}"
        else
          flash["danger"] = game_confirmation_service.errors.join(", ")
          redirect_to "/leagues/#{game.league_id}/games/#{game.id}"
        end
      end
    else
      flash[:warning] = I18n.translate("verification.invalid_code")
      redirect_to "/"
    end
  end

  def destroy
    if game = Game.find params[:id]
      league = game.league!

      if game.unconfirmed?
        Jennifer::Adapter.default_adapter.transaction do
          game.participations.each { |participation| participation.destroy }
          Notification.where { (_source_type == "Game") & (_source_id == game.id) }.destroy

          game.destroy

          flash["success"] = "Game deleted successfully"
          redirect_to "/leagues/#{league.id}"
        end
      else
        flash["warning"] = "Can't delete confirmed games"
        redirect_to "/leagues/#{league.id}/games/#{game.id}"
      end
    else
      flash["warning"] = "Can't find game"
      redirect_to "/"
    end
  end

  def game_params
    params.validation do
      required(:league_id) { |f| !f.nil? }
      required("opponent-id") { |f| !f.blank? }
      required(:status) { |f| !f.blank? }
    end
  end

  private def read_game_logged_notification(game : Game, player : Player | Nil = nil)
    player ||= current_player

    notifications = GameLoggedNotification.unread.where { (_source_id == game.id) & (_player_id == player.try(&.id)) }
    notifications.each(&.read!)
  end

  private def available_opponents(league)
    league.active_players_query.where { _id != current_player.try(&.id) }.order(tag: :asc).to_a
      .map do |player|
        [
          player.id,
          player.display_name
        ]
      end
  end
end
