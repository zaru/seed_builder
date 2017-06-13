require "spec_helper"

# TODO: メタプロで動的にモデルを作れるようにする
class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
  has_many :messages, as: :messagable
end
class Article < ActiveRecord::Base
  has_many :comments
  belongs_to :user
end
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
end
class Company < ActiveRecord::Base
  has_many :messages, as: :messagable
end
class Message < ActiveRecord::Base
  belongs_to :messagable, polymorphic: true
end

RSpec.describe SeedBuilder do
  it "sample spec" do
    binding.pry
  end
end
