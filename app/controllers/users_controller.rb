class UsersController < ApplicationController

  before_filter :rename_params
  before_filter :get_user, :except => [:facebook_login, :save_signature, :save_avatar]

  def index
    # TODO Check if performance can be improved
    # Order appraisals by specific status
    @appraisals = []
    [EActivityValueCreated, EActivityValuePayed, EActivityValueClaimed, EActivityValueFinalized].each do |s|
      @appraisals << Appraisal.where(:created_by => @user.id, :status =>s )
    end
    @appraisals = @appraisals.flatten

    if @appraisals.empty?
      @appraisal = Appraisal.new
      1.times { @appraisal.photos.build }
    end

    respond_to do |format|
      format.html
    end
  end

  def facebook_login
    redirect_to user_omniauth_authorize_path(:facebook)
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(after_sign_in_path_for(@user), :notice => 'Your profile was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { redirect_to(after_sign_in_path_for(@user), :alert => 'Your profile was not updated. Check the input value you gave is correct.') }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def get_user
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    redirect_to root_path if @user.nil?# || @user.role != "admin"
  end

  def update_appraiser_status
    if current_user.role == "admin"
      u = User.find(params[:user])
      u.status = params[:status]
      u.save
       message = Message.new(:name => u.name, :email => u.email)
       UserMailer.notify_appraiser_of_application_result(u,message).deliver
    end
    redirect_to root_path
  end

  def save_json_signature
    u = Appraiser.find(current_user)
    u.appraiser_extra.signature_json = params.except(:controller, :action, :user).to_json
    u.signature = nil
    render :json => u.save
  end

  def new_avatar
    @user = current_user
  end

  def save_avatar
    @user = User.find(current_user)
    @user.avatar = params[:user][:avatar]

    if @user.save
      respond_to do |format|
        format.html # new.html.erb
    end
    else
      render new_avatar
    end
  end

  def crop_avatar
    @user = User.find(current_user)
    if (params[:user])
      @user.crop_avatar_x = params[:user][:crop_avatar_x]
      @user.crop_avatar_y = params[:user][:crop_avatar_y]
      @user.crop_avatar_w = params[:user][:crop_avatar_w]
      @user.crop_avatar_h = params[:user][:crop_avatar_h]
      if @user.save
        redirect_to appraiser_steps_path(:personal), :notice => "Avatar saved succesfully"
      else
        redirect_to new_avatar, :error => "Unable to save avatar. Please try again"
      end
    end
  end

  def new_signature
    @user = current_user
  end

  def save_signature
    @user = Appraiser.find(current_user)
    @user.signature = params[:user][:signature]

    if @user.save
      respond_to do |format|
        format.html # new.html.erb
    end
    else
      render new_signature
    end
  end

  def crop_signature
    @user = User.find(current_user)
    if (params[:user])
      @user.crop_x = params[:user][:crop_x]
      @user.crop_y = params[:user][:crop_y]
      @user.crop_w = params[:user][:crop_w]
      @user.crop_h = params[:user][:crop_h]
      if @user.save
        redirect_to appraiser_steps_path(:signature), :notice => "Signature saved succesfully"
      else
        redirect_to new_signature, :error => "Unable to save signature. Please try again"
      end
    end
  end
end
