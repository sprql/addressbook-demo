# frozen_string_literal: true

# Throttle all requests by IP (60rpm)
#
# Key: "rack::attack:#{Time.now.to_i/:period}:request/ip:#{request_ip}"
Rack::Attack.throttle('request/ip', limit: 300, period: 5, &:ip)
