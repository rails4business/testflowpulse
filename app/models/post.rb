# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group, polymorphic: true, optional: true

  has_rich_text :body

   # 🔹 Callbacks
   before_validation :ensure_unique_slug
  # 🔹 Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  # 🔹 Ordinamenti / Filtri
  SORT_FIELDS = {
    "published" => :sort_published_or_created,
    "updated"   => :updated_at,
    "created"   => :created_at
  }.freeze

  scope :scoped_by, ->(scope) {
    case scope
    when "published" then where.not(published_at: nil)
    when "updated"   then where(published_at: nil)
    else all
    end
  }

  scope :ordered_by, ->(sort, order) {
    field = SORT_FIELDS[sort.presence] || :sort_published_or_created
    dir   = order == "asc" ? :asc : :desc
    order(field => dir)
  }

  scope :search, ->(q) {
    q.present? ? where("title ILIKE :q OR description ILIKE :q", q: "%#{q}%") : all
  }

  scope :date_filtered, ->(mode:, date:, sort:, order:) {
    col = SORT_FIELDS[sort.presence] || :sort_published_or_created
    dir = (order == "asc") ? "up" : "down"

    case mode
    when "year"   then where(arel_table[col].gteq(Time.zone.now.beginning_of_year))
    when "last7"  then where(arel_table[col].gteq(7.days.ago.beginning_of_day))
    when "last30" then where(arel_table[col].gteq(30.days.ago.beginning_of_day))
    when "custom"
      next all if date.blank?
      d = Date.parse(date) rescue nil
      next all unless d
      if dir == "up"
        where(arel_table[col].gteq(d.beginning_of_day))
      else
        where(arel_table[col].lteq(d.end_of_day))
      end
    else
      all
    end
  }

  # 🔹 Utilità
  def duplicate_title?
    self.class.where.not(id: id).exists?(title: title)
  end

  # def to_param
  #   slug.presence || id.to_s
  # end

  # Comodo per export
  def body_html = body&.to_s
  def published_or_created_at = published_at || created_at

  private

  def ensure_unique_slug
    return if title.blank?

    base = title.parameterize
    return if slug.present? && !will_save_change_to_title?

    candidate = base
    n = 2
    while self.class.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
