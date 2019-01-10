# require "../services/password_reset/init"

class PasswordResetController < ApplicationController
  @user : User?

  before_action do
    only %i(edit update) { validate_user }
    only %i(edit update) { check_expiration }
  end

  def new
    page(PasswordReset::NewView)
  end

  def edit
    form = PasswordResetForm.new(user!)
    page(PasswordReset::EditView, form, params[:id].to_s)
  end

  def create
    if user
      PasswordReset::Init.call(user!)

      flash[:info] = "Email sent"
      redirect_to current_user ? user_path(user!) : sign_in_path
    else
      flash[:danger] = "User does not exist"
      page(PasswordReset::NewView)
    end
  end

  def update
    form = PasswordResetForm.new(user!)
    if form.verify(request) && form.save
      session[:user_id] = user!.id

      flash[:success] = t("update.success")
      redirect_to user_path(user!)
    else
      page(PasswordReset::EditView, form, params[:id].to_s)
    end
  end

  private def user
    reset_email = (params["email"]? || params["password_reset[email]"]?)
    @user ||= User.where { _email == reset_email }.first
  end

  private def user!
    user.not_nil!
  end

  private def validate_user
    return if user && user!.activated? && user!.reset_valid?(params[:id])
    flash[:danger] = t("validate_user")
    redirect_to root_path
  end

  private def check_expiration
    return unless user!.password_reset_expired?
    flash[:danger] = t("check_expiration")
    redirect_to new_password_reset_path
  end
end
