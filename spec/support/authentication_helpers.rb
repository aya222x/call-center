module AuthenticationHelpers
  def auth_headers(user, inertia: false)
    token = Auth::JwtService.encode(user_id: user.id)
    headers = { 'Authorization' => "Bearer #{token}" }
    if inertia
      headers['X-Inertia'] = 'true'
      headers['X-Inertia-Version'] = InertiaRails.configuration.version
    end
    headers
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
