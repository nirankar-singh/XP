module ManageNotification
	module AcceptInvite
		extend ActiveSupport::Concern

		def accept_host_notification(invited_user_id, event, current_user)
			user = User.find_by(id: invited_user_id)
			message = "#{current_user.fullname} has accepted your host request."
			content = {
				title: "Accept Host Request", 
				body: message,
				event_id: event.id,
				category: "AcceptHostRequest",
				noti_via_user_id: current_user.id,
				user_id: user.id,
				image: event.event_image
			}
			Notification.create(user_id: user.id, notification_via: current_user.id, notification_title: 'Accept Host Request Request', notification_message: message, category: "AcceptHostRequest", eventDict: {event_id: event.id})
			# send_notification(user.device_token, content)
			ApplePushNotificationJob.new(user.device_token, content).perform_now
		end

		#
		def accept_invite_notification(invited_user_id, event, current_user)
			user = User.find_by(id: invited_user_id)
			message = "#{current_user.fullname} has accepted your join request."
			content = {
				title: "Accept Host Request", 
				body: message,
				event_id: event.id,
				category: "AcceptJoinRequest",
				noti_via_user_id: current_user.id,
				user_id: user.id,
				image: event.event_image
			}
			Notification.create(user_id: user.id, notification_via: current_user.id, notification_title: 'Accept Join Request', notification_message: message, category: "AcceptJoinRequest" , eventDict: {event_id: event.id})
			ApplePushNotificationJob.new(user.device_token, content).perform_now
		end
	end

	#notification for follow and unfollow users
	module Follow
		extend ActiveSupport::Concern

		def send_follow_notification(user)
			p "#{user.inspect}"
			content = {
				title: 'Follow Request',
				body: "#{user.fullname} wants to follow you" ,
				id: user.id,
				fullname: "#{user.fullname}",
				image:  "#{user.image}", 
				category: "FollowRequest"
			}
			Notification.create(userDict: {user_id: user.id}, notification_via: current_user.id, notification_title: 'Follow Request', notification_message: "#{user.fullname} wants to follow you", category: "FollowRequest")
			# send_notification(user.device_token, content)
			ApplePushNotificationJob.new(user.device_token, content).perform_now
		end
	end
end
