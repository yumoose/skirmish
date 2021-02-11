require "../spec_helper"

describe League::RetrievePlayerStats do
  league = create_league
  player = create_player_with_mock_user

  fetch_stats = -> { League::RetrievePlayerStats.new(league: league, player: player).call }

  describe "stats" do
    it "contains the league name" do
      fetch_stats.call[:league_name].should eq league.name
    end

    it "contains the league color" do
      fetch_stats.call[:league_color].should eq league.accent_color
    end

    context "when the player isn't a member of the league" do
      it "has no ratings returned" do
        fetch_stats.call[:ratings].should be_empty
      end
    end

    context "when the player is a member of the league" do
      membership_join_at = 2.days.ago
      membership = Membership.create!(joined_at: membership_join_at, league_id: league.id, player_id: player.id)
      time_formatter = Time::Format.new("%F %T")
      formatted_join_at = time_formatter.format(membership_join_at)

      context "and hasn't played any games" do
        it "contains two entries" do
          fetch_stats.call[:ratings].size.should eq 2
        end

        it "has an entry rating" do
          fetch_stats.call[:ratings][formatted_join_at].should eq league.start_rating
        end

        it "has a current rating" do
          fetch_stats.call[:ratings][time_formatter.format(Time.local)].should eq league.start_rating
        end
      end

      context "and has played games" do
        another_player = create_player_with_mock_user
        Membership.create!(league_id: league.id, player_id: another_player.id)

        game_logger = League::LogGame.new(league: league, winner: player, loser: another_player, logger: player)
        game_logger.call
        game = game_logger.game

        context "that haven't been confirmed" do
          it "doesn't contain entries for unconfirmed games" do
            fetch_stats.call[:ratings].size.should eq 2
          end

          it "has an entry rating" do
            fetch_stats.call[:ratings][formatted_join_at].should eq league.start_rating
          end

          it "has a current rating" do
            fetch_stats.call[:ratings][time_formatter.format(Time.local)].should eq league.start_rating
          end
        end

        Game::Confirm.new(game: game, confirming_player: another_player).call
        game_confirmed_at = 1.day.ago
        game.update!(confirmed_at: game_confirmed_at)
        latest_player_rating = player.participations.last.not_nil!.rating

        it "contains an entry for each confirmed game played" do
          fetch_stats.call[:ratings].size.should eq 3
        end

        it "has an entry rating" do
          fetch_stats.call[:ratings][formatted_join_at].should eq league.start_rating
        end

        it "has a current rating" do
          fetch_stats.call[:ratings][time_formatter.format(Time.local)].should eq latest_player_rating
        end

        it "has a rating for the confirmed game" do
          fetch_stats.call[:ratings][time_formatter.format(game_confirmed_at)].should eq latest_player_rating
        end
      end
    end
  end
end
