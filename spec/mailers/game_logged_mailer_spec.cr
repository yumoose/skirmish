require "./spec_helper"

describe GameLoggedMailer do
  describe "recipient" do
    it "is addressed to the user's email" do
      league = create_league
      _, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      user = player.user!
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      recipient = mailer.to.first
      recipient.email.should eq user.email
    end

    it "is addressed to the player's tag" do
      league = create_league
      _, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      recipient = mailer.to.first
      recipient.name.should eq player.tag
    end
  end

  describe "sender" do
    it "is from the games address" do
      league = create_league
      _, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      sender = mailer.from
      sender.should eq ApplicationMailer::FROM_GAMES
    end
  end

  describe "subject" do
    it "is a nice welcome message" do
      league = create_league
      winner_and_logger, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      mailer.subject.should eq I18n.translate("mailer.game_logged.subject", { logger: winner_and_logger.tag })
    end
  end

  describe "content" do
    it "contains the mailer title" do
      league = create_league
      _, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      mailer.html.should contain HTML.escape(I18n.translate("mailer.game_logged.title"))
      mailer.text.should contain I18n.translate("mailer.game_logged.title")
    end

    context "when the player has lost the game" do
      it "asks the user to confirm their loss" do
        league = create_league
        _, _, loser_and_confirmer = create_and_pit_players(league)

        player = loser_and_confirmer
        game = league.games.first

        mailer = GameLoggedMailer.new(player, game)

        mailer.html.should contain HTML.escape(I18n.translate("mailer.game_logged.confirmation.lose_content"))
        mailer.text.should contain I18n.translate("mailer.game_logged.confirmation.lose_content")
      end
    end

    context "when the player has won the game" do
      it "asks the user to confirm their win" do
        league = create_league
        player_one = create_player_with_mock_user
        player_two = create_player_with_mock_user
        Membership.create!(player_id: player_one.id, league_id: league.id, joined_at: Time.local)
        Membership.create!(player_id: player_two.id, league_id: league.id, joined_at: Time.local)

        game_logger = League::LogGame.new(league: league, winner: player_one, loser: player_two, logger: player_two)
        game_logger.call
        game = league.games.first

        mailer = GameLoggedMailer.new(player_one, game)

        mailer.html.should contain HTML.escape(I18n.translate("mailer.game_logged.confirmation.win_content"))
        mailer.text.should contain I18n.translate("mailer.game_logged.confirmation.win_content")
      end
    end

    it "contains a link to confirm the game" do
      league = create_league
      _, _, loser_and_confirmer = create_and_pit_players(league)

      player = loser_and_confirmer
      game = league.games.first

      mailer = GameLoggedMailer.new(player, game)

      verification_link = "#{ENV["BASE_URL"]}/leagues/#{league.id}/games/#{game.id}"

      mailer.html.should contain verification_link
      mailer.text.should contain verification_link
    end
  end
end
