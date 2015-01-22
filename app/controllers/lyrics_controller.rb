class LyricsController < ApplicationController
	
	before_action :tag_cloud, :only => [:index, :tagged]
	has_scope :by_tags
	load_and_authorize_resource :only => [:show, :edit, :update, :destroy]
	before_action :find_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
	before_action :set_campaign, except: [:upvote, :downvote]
	before_action :authenticate_user!, except: [:index, :show, :tagged]
	impressionist :actions => [:show,:index], :unique => [:impressionable_type, :impressionable_id, :session_hash]
	
	
	

	def index

		case params[:sort_by]
	      when 'most_liked'
	        @lyrics = apply_scopes(Lyric).all.order(:cached_votes_up => :desc).paginate(:page => params[:page], :per_page => 10)
	       when 'most_viewed'
	        @lyrics = apply_scopes(Lyric).all.order(:counter_cache => :desc).paginate(:page => params[:page], :per_page => 10)
	      when 'most_recent'
	        @lyrics = apply_scopes(Lyric).all.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
	      else
	        @lyrics = apply_scopes(Lyric).all.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
	    end

	end

	def show
		@comments = Comment.where(lyric_id: @lyric)
		@random_lyric = Lyric.where.not(id: @lyric).order("RANDOM()").first
		@random_lyrics = Lyric.where.not(id: @lyric).order("RANDOM()").take(5)

		if @lyric == Lyric.last
			@next_lyric = Lyric.order(id: :asc).first
		else
			@next_lyric = Lyric.where("id > ?", @lyric).order(id: :asc).first
		end

		if @lyric == Lyric.first
			@previous_lyric = Lyric.order(id: :asc).last
		else
			@previous_lyric = Lyric.where("id < ?", @lyric).order(id: :desc).first
		end
		
	end

	def new
		@lyric = Lyric.new
	end

	def create
		@lyric = Lyric.new(post_params)
		@lyric.user_id = current_user.id
		@lyric.campaign_id = @campaign.id

		if @lyric.save
			redirect_to([@lyric.campaign, @lyric])
		else
			render 'new'
		end

	end

	def edit
	end

	def update
		if @lyric.update(post_params)
			redirect_to([@lyric.campaign, @lyric])
		else
			render 'edit'
		end

	end

	def destroy
		@lyric.destroy
		redirect_to root_path
	end

	def upvote
		@lyric.upvote_by current_user
		redirect_to :back
	end

	def downvote
		@lyric.downvote_by current_user
		redirect_to :back
	end

	def tagged

  		if params[:tag].present? 
    		@lyrics = Lyric.tagged_with(params[:tag]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
  		else 
    		@lyrics = apply_scopes(Lyric).all.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)

  		end  
	end

	def tag_cloud
		
   		 @tags = Lyric.tag_counts_on(:tags)
  	end


	private

	def find_post
		@lyric = Lyric.find(params[:id])
	end

	def set_campaign
		@campaign = Campaign.find(params[:campaign_id])
	end


	def post_params
		params.require(:lyric).permit(:line, :description, :artist, :song, :album, :link, :tag_list)
	end

end
