class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :destroy, :update, :edit]
  rescue_from ActiveRecord::RecordNotFound, with: :record_rescue

  def index
    @posts = Post.all.includes(:comments).order("created_at desc")
    search_attribute = params[:search]
    if search_attribute
      @posts = Post.search_for(params[:search])
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(allowed_params_post)
    if @post.save
      array = allowed_params_tags[:title].split(" ")
      array.each do |tag|
        find = Tag.find_by(title: tag)
        if find
          forum_tag = ForumTag.create(
                                      post_id: @post.id,
                                      tag_id: find.id
                                      )
        else
          obj_tag = Tag.create(
                              title: tag
                              )
          forum_tag = ForumTag.create(
                                      post_id: @post.id,
                                      tag_id: obj_tag.id
                                      )
        end
      end
      flash[:success] = "Succesfully created post."
      redirect_to "/"
    else
      @post.errors.full_messages.each do |error|
        flash[:danger] = "#{error}"
        render "new.html.erb"
      end
    end
  end

  def show
    @comment = Comment.new
    @post = Post.find(params[:id])
    gon.post_id = @post.id
    if current_user
      gon.current_user_id = current_user.id
    end
    @comments = @post.comments.order("created_at")
    ip_address = request.remote_ip
    visited = false
    @post.visits.each do |visit|
      if visit.ip_address == ip_address
        visited = true
      end
    end
    if visited == false
      visit = Visit.create(ip_address: ip_address)
      post_visit = PostVisit.create(
                                    post_id: @post.id,
                                    visit_id: visit.id
      )
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.assign_attributes(allowed_params_post)
    if @post.save
      array = allowed_params_tags[:title].split(" ")
      if array.empty?
        ForumTag.where(post_id: @post.id).destroy_all
      else
        ForumTag.where(post_id: @post.id).destroy_all
        array.each do |tag|
          find = Tag.find_by(title: tag)
          if find
            forum_tag = ForumTag.create(
                                        post_id: @post.id,
                                        tag_id: find.id
                                        )
          else
            obj_tag = Tag.create(
                                title: tag
                                )
            forum_tag = ForumTag.create(
                                        post_id: @post.id,
                                        tag_id: obj_tag.id
                                        )
          end
        end
      end
      flash[:success] = "Succesfully edited post."
      redirect_to "/post/#{ @post.id }"
    else
        @post.errors.full_messages.each do |error|
          flash[:danger] = "#{error}"
          redirect_to "/post/#{ @post.id }/edit"
        end
    end
  end

  def edit
    @post = Post.find(params[:id])
    @tag_collection = @post.tag_collection
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to("/")
  end

  private

  def allowed_params_post
    params.require(:post).permit(:user_id, :title, :content, :post_image)
  end

  def allowed_params_tags
    params.require(:tags).permit(:title)
  end

  def record_rescue
    redirect_to "/"
  end

end
