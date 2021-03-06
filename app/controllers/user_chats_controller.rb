class UserChatsController < ApplicationController
  before_action :authenticate_user!

  def create
      if user = User.find_by(username: user_chats_params[:user_id])
        @user_chat = UserChat.new(user_id: user.id, chat_id: user_chats_params[:chat_id])
        if @user_chat.save
          redirect_to "/chats/#{user_chats_params[:chat_id]}"
        else
          flash[:warning] = "#{user.username} is already in this chatroom."
          redirect_to "/chats/#{user_chats_params[:chat_id]}"
        end
      else
        flash[:warning] = "User does not exist."
        redirect_to "/chats/#{user_chats_params[:chat_id]}"
      end
  end

  def destroy
    user = User.find(params[:id])
    user_chat = UserChat.where(user_id: user.id)
    if user_chat_find = user_chat.find_by(chat_id: params[:chat_id])
      user_chat_find.destroy
      redirect_to "/chats/#{params[:chat_id]}"
    end
  end

  private

  def user_chats_params
    params.require(:user_chat).permit(:user_id, :chat_id)
  end

end
