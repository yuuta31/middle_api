require 'faraday'

module End
  module Api
    module V1
      class Base
        class RecordDuplicated < StandardError; end
        class RecordInvalid < StandardError; end

        class << Base
          def arrow_options_keys = %i[timeout]
          def default_headers = { "Content-Type": "application/json" }
          def endpoint_host = ENV.fetch("END_API_HOST", nil)
          def endpoint_url = endpoint_host ? "https://#{endpoint_host}" : "http://host.docker.internal:10086"

          def common_retry_options
            {
              max: 3,
              interval: 0.5,
              interval_randomness: 0,
              backoff_factor: 0.25,
              exceptions: [
                Errno::ETIMEDOUT, "Timeout::Error", Faraday::TimeoutError,
                Faraday::ConnectionFailed, Faraday::ClientError, Faraday::RetriableResponse
              ]
            }
          end

          def request_with_options(method, url, params: {}, options: {}, headers: {})
            raise ArgumentError, "有効なリクエストではありません。" unless %i[get post patch put delete].include?(method)

            headers = headers.merge(default_headers)
            connection = Faraday.new(endpoint_url) do |conn|
              options.each_key do |key|
                next unless arrow_options_keys.include?(key)

                conn.options.public_send("#{key}=", options[key])
              end

              conn.request(:retry, common_retry_options) if common_retry_options.keys.count.positive?
            end

            case method
            when :get, :delete
              res = connection.public_send(method, url, params, headers)
            when :post, :put, :patch
              res = connection.public_send(method, url, params.to_json, headers)
            end
            return_response(res)
          end

          def return_response(res)
            case res.status
            when 200
              JSON.parse(res.body)
            when 400
              Rails.logger.error(res.inspect)
              raise RecordInvalid, res.inspect
            when 404
              Rails.logger.error(res.inspect)
              nil
            when 409
              Rails.logger.error(res.inspect)
              raise RecordDuplicated, res.inspect
            else
              Rails.logger.error(res.inspect)
              raise res.inspect
            end
          end
        end
      end
    end
  end
end
