# encoding: UTF-8

class Idea < ActiveRecord::Base
  attr_accessible :title, :problem, :solution, :metrics, :deadline, :author, :design_size, :development_size, :rating, :category, :product_manager, :active_at

  belongs_to :author, :class_name => 'User'
  belongs_to :account
  has_many   :vettings, :dependent => :destroy
  has_many   :votes, :as => :subject, :dependent => :destroy
  has_many   :comments
  has_many   :toplevel_comments, :class_name => 'Comment', :as => :parent
  has_many   :attachments, :class_name => 'Attachment', :as => :owner, :dependent => :destroy
  belongs_to :product_manager, :class_name => 'User'

  include Notification::Base::CanBeSubject
  include Idea::StateMachine

  has_many   :commenters, :class_name => 'User', :through => :comments, :source => :author
  has_many   :vetters,    :class_name => 'User', :through => :vettings, :source => :user
  has_many   :backers,    :class_name => 'User', :through => :votes,    :source => :user
  has_many   :bookmarks,  :class_name => 'User::Bookmark', :dependent => :destroy
  has_many   :bookmarkers, :through => :bookmarks, :source => :idea

  validates_presence_of  :author
  validates_presence_of  :account
  validates_presence_of  :rating
  validates_presence_of  :title, :problem, :solution, :metrics
  validates_inclusion_of :design_size,      :in => 1..4, :allow_nil => true
  validates_inclusion_of :development_size, :in => 1..4, :allow_nil => true
  validates_inclusion_of :category, in: lambda { |idea| idea.account.categories }, allow_nil:true

  default_values rating: 0

  scope :managed_by,     lambda { |user| where(product_manager_id: user) }
  scope :not_vetted_by,  lambda { |user| where('ideas.id NOT IN (?)', user.vetted_ideas.value_of(:id)) }
  scope :backed_by,      lambda { |user| joins(:votes).where('votes.user_id = ?', user.id) }

  # Other helpers

  def participants
    User.where id:(
      self.votes.value_of(:user_id) +
      self.vettings.value_of(:user_id) +
      self.comments.value_of(:author_id) +
      [self.author.id]
    ).uniq
  end


  def sized?
    design_size.present? && development_size.present?
  end

  def size
    sized? and [design_size, development_size].max
  end


  # Search angles
  
  def self.discussable_by(user)
    user.account.ideas
  end

  def self.vettable_by(user)
    discussable_by(user).with_state(:submitted)
  end

  def self.votable_by(user)
    discussable_by(user).with_state(:vetted, :voted)
  end

  def self.pickable_by(user)
    discussable_by(user).with_state(:voted)
  end

  def self.approvable_by(user)
    discussable_by(user).with_state(:designed)
  end

  def self.signoffable_by(user)
    discussable_by(user).with_state(:implemented)
  end

  def self.buildable_by(user)
    discussable_by(user).with_state(:picked, :designed, :approved, :implemented, :signed_off)
  end

  def self.followed_by(user)
    user.bookmarked_ideas
  end


  # Search orders


  def self.by_rating
    order('COALESCE(1000 * ideas.rating / (ideas.development_size + ideas.design_size), -1) DESC')
    # order('(1000 * ideas.rating / (ideas.development_size + ideas.design_size)) DESC')
  end

  def self.by_activity
    order('ideas.active_at DESC')
  end

  def self.by_progress
    order('ideas.state DESC')
  end

  def self.by_creation
    order('ideas.created_at DESC')
  end

  def self.by_size
    order('(ideas.development_size + ideas.design_size)')
  end



  # Search filters

  def self.authored_by(user)
    where(author_id: user.id)
  end

  def self.commented_by(user)
    joins(:comments).where('comments.author_id = ?', user.id).group('ideas.id')
  end

  def self.vetted_by(user)
    joins(:vettings).where('vettings.user_id = ?', user.id).group('ideas.id')
  end

  def self.backed_by(user)
    joins(:votes).where('votes.user_id = ?', user.id).group('ideas.id')
  end


  # called from subresources (comments, vettings, votes)
  def ping!
    update_attributes! active_at: Time.now
  end


  private


  before_save do |record|
    unless record.updated_at.nil?
      record.active_at = record.updated_at if record.active_at.nil? || record.updated_at > record.active_at
    end
  end

end
