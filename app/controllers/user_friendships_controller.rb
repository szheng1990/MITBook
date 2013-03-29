class UserFriendshipsController < ApplicationController
    before_filter :authenticate_user! #only: [:new]
    def index
       @user_friendships =current_user.user_friendships.all 
    end


    def new

       if params[:friend_id]
          @friend = User.find(params[:friend_id])
          @user_friendship = current_user.user_friendships.new(friend: @friend)
          #render action: :new #optional
       else
          flash[:error] = "Friend Required"
       end

       rescue ActiveRecord::RecordNotFound
          render file: 'public/404', status: :not_found

    end

    def create
        if params[:user_friendship] && params[:user_friendship].has_key?(:friend_id)
           @friend = User.find(params[:user_friendship][:friend_id])
           @user_friendship = UserFriendship.request(current_user, @friend)
           if @user_friendship.new_record? # new record means not saved! yet
               flash[:error] = "There was problem creating that friend request."
           else
               flash[:success] = "Friend request sent."
           end
           redirect_to profile_path(@friend.profile_name)

        else
           flash[:error] = "Friend Required"
           redirect_to root_path
        end
    end

    def accept
        @user_friendship = current_user.user_friendships.find(params[:id])
        if @user_friendship.accept! #linked to state machine
           flash[:success] = "You are now friends with #{@user_friendship.friend.full_name}!"
        else
           flash[:error] = "Unable to friend #{user_friendship.friend}, please retry"   
        end
        redirect_to user_friendships_path
    end

    def edit 
        @user_friendship = current_user.user_friendships.find(params[:id])
        @friend = @user_friendship.friend
    end

    def destroy
        @user_friendship = current_user.user_friendships.find(params[:id])
        @friend = @user_friendship.friend 
        if @user_friendship.delete
           flash[:success] = "you are no longer friends with #{@friend.full_name}"
        else
           flash["error"] = "Unable to delete #{@friend.full_name}. Please retry"
        redirect_to user_friendships_path
        end
    end
end
