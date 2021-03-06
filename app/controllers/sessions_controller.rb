# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter :authenticate

  # ログイン
  def callback
    auth = request.env["omniauth.auth"]

    user = User.where( provider: auth["provider"], uid: auth["uid"] ).first || User.create_with_omniauth( auth )
    user.auth_update( auth )

    session[:user_id] = user.id
    session[:oauth_token] = auth['credentials']['token']
    session[:oauth_token_secret] = auth['credentials']['secret']


    # 保管URLへリダイレクト
    unless session[:request_url].blank?
      redirect_to session[:request_url]
      session[:request_url] = nil
      return
    end

    redirect_to memos_path
  end

  # ログアウト
  def destroy
    session[:user_id] = nil

    redirect_to :root
  end

  # ログインエラー
  def failure
    render text: "<span style='color: red;'>Auth Failure</span>"
  end
end
