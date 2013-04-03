class UserFriendshipsController < ApplicationController
    before_filter :authenticate_user! #only: [:new]
    respond_to :html, :json

    def index
       @user_friendships =current_user.user_friendships.all 
    end


    def new

       if params[:friend_id]
          @friend = User.find(params[:friend_id])
          raise ActiveRecord::RecordNotFound if @friend.nil?
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
           respond_to do |format|
             if @user_friendship.new_record? # new record means not saved! yet
                format.html do 
                 flash[:error] = "There was problem creating that friend request."
                 redirect_to profile_path(@friend.profile_name)
                end
                format.json { render json: @user_friendship.to_json, status: :precondition_failed}
             else
                format.html do 
                 flash[:notice] = "Friend request sent."
                 redirect_to profile_path(@friend.profile_name)
                end 
                format.json {render json: @user_friendship.to_json }
             end
             
           end

        else
           flash[:error] = "Friend Required"
           redirect_to root_path
        end
    end

    def accept
        @user_friendship = current_user.user_friendships.find(params[:id])
        if @user_friendship.update_attributes(:state => 'accepted') && 
           @user_friendship.accept_mutual_friendship! #linked to state machine
           flash[:notice] = "You are now friends with #{@user_friendship.friend.full_name}!"
        else
           flash[:error] = "Unable to friend #{user_friendship.friend}, please retry"   
        end
        redirect_to user_friendships_path
    end

    def edit 
        if params[:friend_id] # get user_friendship by friend id

            @user_friendship = current_user.user_friendships.where(friend_id: params[:friend_id]).first.decorate
            @friend = @user_friendship.friend
        else #get user_friendship by friendship id
            @user_friendship = current_user.user_friendships.find(params[:id]).decorate
            @friend = @user_friendship.friend
        end 
    end

    def destroy
        @user_friendship = current_user.user_friendships.find(params[:id])
        @friend = @user_friendship.friend 
        if @user_friendship.destroy
           flash[:notice] = "you are no longer friends with #{@friend.full_name}"
        else
           flash["error"] = "Unable to delete #{@friend.full_name}. Please retry"      
        end
        redirect_to user_friendships_path
    end
end
