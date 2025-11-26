module Openai
  module RetryHandler
    MAX_RETRIES = 5
    BASE_DELAY = 2 # seconds
    MAX_DELAY = 60 # seconds

    def with_retry(max_retries: MAX_RETRIES, &block)
      attempt = 0

      begin
        attempt += 1
        block.call
      rescue Faraday::TooManyRequestsError, Faraday::ServerError => e
        if attempt <= max_retries
          delay = calculate_delay(attempt)
          Rails.logger.warn("OpenAI API rate limit hit. Retrying in #{delay}s (attempt #{attempt}/#{max_retries})")
          sleep(delay)
          retry
        else
          raise StandardError, "Max retries (#{max_retries}) exceeded. Last error: #{e.message}"
        end
      end
    end

    private

    def calculate_delay(attempt)
      # Exponential backoff with jitter: 2^attempt + random(0-1)
      delay = BASE_DELAY ** attempt + rand
      [delay, MAX_DELAY].min
    end
  end
end
