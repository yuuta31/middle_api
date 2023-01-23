module End
  module Api
    module V1
      class Project < End::Api::V1::Base
        class << Project
          def default_options = { timeout: 60 }

          def get_with_options(project_id: nil, options: {})
            request_with_options(:get, "/#{project_id}", options: options.merge(default_options))
          end

          def create_with_options(params, options: {})
            request_with_options(:post, "/projects", params: params, options: options.merge(default_options))
          end

          def update_with_options(params, project_id: nil, options: {})
            request_with_options(:patch, "/#{project_id}", params: params, options: options.merge(default_options))
          end
        end
      end
    end
  end
end
