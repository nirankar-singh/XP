class Api::V1::SearchController < Api::V1::BaseController
	respond_to :json
	before_action :activated_user, only: [:posts, :users]
	
	def posts
		follow_users_ids = current_user.following_relationships.where(follow_status: 2).pluck(:following_id)
		blocked_users_ids = current_user.blocks.pluck(:block_user_id)
		restrict_users_ids = follow_users_ids + blocked_users_ids 

		blocked_posts_ids = current_user.post_blocks.pluck(:post_id)
		
		search_data = PostEvent.where.not(id: blocked_posts_ids).order('created_at desc').paginate(page:params[:page], per_page: params[:per_page])
		
		final_data = search_data.includes(:user, :post_likes, :comments).map{
			|x| x.as_json.merge(
				user: x.user.as_json(only:[:id, :fullname, :image]),
				like: x.post_likes.size,
				like_flag: (x.post_likes.collect(&:user_id).include?(current_user.id) ? 1 : 0),
				comment: x.comments.size 
			)
		}
		render json: {allPosts: final_data, responseCode: 1}, status: 200
	end

	def users
		follow_users_ids = current_user.following.pluck(:id)
		block_users_ids = current_user.blocks.pluck(:block_user_id)
		users = User.where.not(admin_flag: 1).where.not(id: block_users_ids).where.not(id: follow_users_ids).where.not(id: current_user.id)
		search_data = users.within(params[:radius], :origin => [params[:latitude].to_f.round(4),params[:longitude].to_f.round(4)]).paginate(page: params[:page], per_page: params[:per_page])
		final_data = search_data.as_json(only: [:id, :fullname, :image, :authentication, :description, :age, :gender, :about_me, :occupation, :interest, :cover_image_link, :cover_image_name, :dob, :facebook_uid, :latitute, :longitute])
		render json: {users: final_data, responseCode: 1}, status: 200
	end

	def all_users
		users = User.where.not(admin_flag: 1).where('users.fullname ILIKE (?)', "%#{params[:data]}%")
		final_data = users.as_json(only: [:id, :fullname, :image, :image_name, :authentication_token])
		render json: {users: final_data, responseCode: 1}, status: 200
	end

	def events
		events = CurrentEvent.where('title ILIKE (?) OR keywords ILIKE (?) OR sub_title ILIKE (?)', "%#{params[:data]}%", "%#{params[:data]}%", "%#{params[:data]}%")

		claimed_events = events.where(is_claim_location: true)
		
		not_expired_events = events.where(is_claim_location: false).where.not( availability: 1).select{|x| x.end_event_date.to_datetime >= DateTime.current.to_datetime}

		ongoing_events = claimed_events + not_expired_events

		final_data = ongoing_events.as_json
		render json: {events: final_data, responseCode: 1}, status: 200
	end
end
