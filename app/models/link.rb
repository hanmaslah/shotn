class Link < ApplicationRecord
  require 'pismo'
  belongs_to :user, optional: true

  scope :most_recent, (lambda do
                         where(deleted: false)
                         .limit(5)
                         .select('title', 'full_url', 'vanity_string',
                                 'created_at')
                       end)
  scope :most_popular, (lambda do
                         where(deleted: false)
                         .limit(5)
                         .select('title', 'full_url', 'vanity_string',
                                 'clicks')
                       end)
  scope :links, ->(user) { where(user_id: user.id).order('created_at desc') }

  validates :full_url, presence: true, url: true
  validates :vanity_string, presence: true, uniqueness: true,
                            length: { maximum: 6 }
  after_create :link_title

  def link_title
    self.title = Pismo::Document.new(full_url).title
    save
  end

  def self.vanity
    SecureRandom.urlsafe_base64(4)
  end
end
