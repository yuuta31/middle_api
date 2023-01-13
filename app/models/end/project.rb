module End
  class Project
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :id, :string
    attribute :name, :string
    attribute :description, :string

    validates :name, presence: true
    validates :description, presence: true

    before_validation :check_and_raise_name

    BANNED_WORDS = ["放送禁止用語1", "放送禁止用語2", "放送禁止用語3"]
    DISCRIMINATION_WORDS = ["差別用語1", "差別用語2", "差別用語3"]

    def self.call(...) = new(...)

    def find
      project = End::Api::V1::Project.get_with_options(project_id: id) if id.presence
      raise "プロジェクトが見つかりません" if project.nil?

      project
    end

    def save!
      raise errors.full_messages.inspect if invalid?

      project = find_by if id.presence
      project.nil? ? create! : update!(project)
    end

    private

    def find_by = End::Api::V1::Project.get_with_options(project_id: id)
    def params = { project: { name: name, description: description, }.compact }
    def create! = End::Api::V1::Project.create_with_options(params)

    def update!(project)
      update_params = { project: project }.merge(params)
      End::Api::V1::Project.update_with_options(update_params, project_id: id)
    end

    def check_and_raise_name
      raise "放送禁止用語が含まれています。" if BANNED_WORDS.include?(name)
      raise "差別用語が含まれています。" if DISCRIMINATION_WORDS.include?(name)
    end
  end
end
