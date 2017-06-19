# TODO: メタプロで動的にモデルを作れるようにする
class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
  # has_many :messages, as: :messagable
end
class Article < ActiveRecord::Base
  has_many :comments
  # has_many :article_tags
  # has_many :tags, through: :article_tags
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
class Product < ActiveRecord::Base
  has_many :reviews
end
class Book < Product
end
class Movie < Product
end
class Review < ActiveRecord::Base
  belongs_to :product
end
class Tag < ActiveRecord::Base
  has_many :article_tags
  has_many :articles, through: :article_tags
end
class ArticleTag < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
end
class Account < ActiveRecord::Base
  has_and_belongs_to_many :roles
end
class Administrator < Account
end
class Role < ActiveRecord::Base
  has_and_belongs_to_many :accounts
end
class Blog < ActiveRecord::Base
  validates :title, presence: true,length: { in: 2..3 }
  validates :number, presence: true, numericality: { only_integer: true, odd: true }
  validates :unique_id, presence: true, uniqueness: true
end

class PhotoUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_whitelist
    %w(png)
  end
end
class Photo < ActiveRecord::Base
  mount_uploader :file, PhotoUploader
end
