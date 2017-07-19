class ShortenedURL < ActiveRecord::Base
  validates :user_id, :long_url, :short_url, presence: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit

  has_many :visitors,
      Proc.new { distinct },
      through: :visits,
      source: :visitor

  def self.generate(user, long_url)
    n = self.new(long_url: long_url)
    n.submitter = user
    n.short_url = self.random_code
    n.save
    n
  end

  def self.random_code
    shortened = SecureRandom.urlsafe_base64[0..15]
    while ShortenedURL.find_by short_url: shortened
      shortened = SecureRandom.urlsafe_base64[0..15]
    end
    shortened
  end

  def clicks
    self.visits.count
  end

  def num_uniques
    self.visits.select(:user_id).count
  end

  def num_recent_uniques
    ago = 10.minutes.ago
    self.visits
        .select(:user_id)
        .where("created_at > :ago", ago: ago)
        .count
  end

end
