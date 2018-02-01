class Api::V1::ReportsController < Api::V1::BaseController
	before_action :activated_user, only: [:abuse]

	#reports : users, posts, events
	def abuse
		if params[:user_id].present?
			user = User.find_by(id: params[:user_id])
			msg = report_abuse(user, params[:content])
			Thread.new{
				ReportMailer.send_report_user(current_user, user.reportable).deliver_now
			}
		elsif params[:event_id].present?
			event = CurrentEvent.find_by(id: params[:event_id])
			msg = report_abuse(event, params[:content])
			Thread.new{
				ReportMailer.send_report_event(current_user, event.reportable).deliver_now
			}
		elsif params[:post_id].present?
			post = PostEvent.find_by(id: params[:post_id])
			msg = report_abuse(post, params[:content])
			Thread.new{
				ReportMailer.send_report_post(current_user, post.reportable).deliver_now
			}
		elsif params[:group_id].present?
			group = Group.find_by(id: params[:group_id])
			msg = report_abuse(group, params[:content])	
		end
		render json: {message: msg, responseCode: 1}, status: 200
	end

	def report_abuse(reported_for, content)
		report = reported_for.reports.find_by(user_id: current_user.id)
		Thread.new{
			ClaimMailer.send_report_mailer(event_claim).deliver_now
		}
		if report.present?
			msg = 'You have already reported for this.'
		else
			reported_for.reports.create(user_id: current_user.id, content: content)
			msg = 'Your request has been recieved.'
		end
		return msg
	end
end
