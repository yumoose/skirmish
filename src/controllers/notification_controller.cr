class NotificationController < ApplicationController
  before_action do
    all { redirect_signed_out_user }
  end

  def index
    player = current_player.not_nil!

    total_items = Notification.for_player(player).count
    last_page = total_items / per_page + 1
    notifications = Notification.for_player(player).order(created_at: :desc).limit(per_page).offset(offset)

    render("index.slang")
  end

  def show
    player = current_player.not_nil!

    if notification = Notification.find(params[:id])
      if notification.player_id != player.id
        flash[:danger] = "Can't find notification"
        redirect_to "/notifications"; return
      end

      notification.read!

      redirect_to notification.action_url
    else
      flash[:danger] = "Can't find notification"
      redirect_to "/notifications"
    end
  end

  def read
    player = current_player.not_nil!
    notification = Notification.find(params[:id])

    if notification && notification.player_id == player.id
      notification.read!
    else
      flash[:danger] = "Can't find notification"
    end

    redirect_to "/notifications"
  end

  def read_all
    player = current_player.not_nil!

    notifications = Notification.where { _player_id == player.id }.where { _read_at == nil }
    notifications.update(read_at: Time.local)

    redirect_to "/notifications"
  end

  private def page_number
    (params[:page]? || 1).to_i
  end

  private def per_page
    10
  end

  private def offset
    (page_number - 1) * per_page
  end
end
