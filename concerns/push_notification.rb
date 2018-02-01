module PushNotification
	extend ActiveSupport::Concern
	included do
      	def send_notification(device_token, content)
      		p "yipeeee m here"
	      	pusher = Grocer.pusher(
	            certificate: Rails.root.join('ck.pem'), 
	            passphrase:  "123456789",                    
	            gateway:     "gateway.push.apple.com",
	            port:        2195                   
	           # retries:     3                      
			)
	        notification = Grocer::Notification.new(
	            device_token:      device_token,
	            alert:             content,
	            badge:             42,
	            sound:             "default"
	        )
	        pusher.push(notification)
	    end
    end
end
