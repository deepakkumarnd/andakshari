class GameRoom
  REDIS_TTL    = 24.hours.to_i
  MAX_PLAYERS  = 6
  MAX_WATCHERS = 10
  STATUSES     = %w[waiting playing finished].freeze
  INDEX_KEY    = "game_rooms:index"

  attr_reader :id, :host_user_id, :status, :created_at

  def initialize(id:, host_user_id:, status: "waiting", created_at: nil)
    @id           = id
    @host_user_id = host_user_id.to_i
    @status       = status
    @created_at   = created_at
  end

  # ── Class methods ─────────────────────────────────────────────────────────

  def self.find(id)
    return nil unless id
    data = REDIS.hgetall("game_room:#{id}")
    return nil if data.empty?
    new(id: id, host_user_id: data["host_user_id"], status: data["status"], created_at: data["created_at"])
  end

  def self.create!(user:)
    id = SecureRandom.uuid
    REDIS.hset("game_room:#{id}",
      "host_user_id", user.id,
      "status",       "waiting",
      "created_at",   Time.current.iso8601
    )
    REDIS.expire("game_room:#{id}", REDIS_TTL)
    REDIS.sadd(INDEX_KEY, id)
    new(id: id, host_user_id: user.id)
  end

  def self.all_empty
    REDIS.smembers(INDEX_KEY).filter_map do |id|
      room = find(id)
      room if room && room.participants_empty?
    end
  end

  # ── Attributes ────────────────────────────────────────────────────────────

  def user_id; host_user_id; end

  def user
    @user ||= User.find_by(id: host_user_id)
  end

  def waiting?;  status == "waiting";  end
  def playing?;  status == "playing";  end
  def finished?; status == "finished"; end

  def to_param; id; end

  # ── Participants ──────────────────────────────────────────────────────────

  def participants
    raw = REDIS.hgetall("game_room:#{id}:participants")
    return [] if raw.empty?
    users_by_id = User.where(id: raw.keys.map(&:to_i)).index_by { |u| u.id.to_s }
    raw.filter_map do |uid, role|
      user = users_by_id[uid]
      user && GameParticipant.new(user: user, game_room: self, role: role)
    end
  end

  def players
    participants.select(&:player?)
  end

  def watchers
    participants.select(&:watcher?)
  end

  def players_full?
    REDIS.hgetall("game_room:#{id}:participants").count { |_, r| r == "player" } >= MAX_PLAYERS
  end

  def watchers_full?
    REDIS.hgetall("game_room:#{id}:participants").count { |_, r| r == "watcher" } >= MAX_WATCHERS
  end

  def participants_empty?
    REDIS.hlen("game_room:#{id}:participants") == 0
  end

  def participant(user)
    return nil unless user
    role = REDIS.hget("game_room:#{id}:participants", user.id.to_s)
    return nil unless role
    GameParticipant.new(user: user, game_room: self, role: role)
  end

  def add_participant!(user:, role:)
    REDIS.hset("game_room:#{id}:participants", user.id.to_s, role)
    REDIS.expire("game_room:#{id}:participants", REDIS_TTL)
    GameParticipant.new(user: user, game_room: self, role: role)
  end

  def remove_participant!(user:)
    REDIS.hdel("game_room:#{id}:participants", user.id.to_s)
    REDIS.hdel("game_room:#{id}:connected_at", user.id.to_s)
  end

  # ── Voice presence ────────────────────────────────────────────────────────

  def record_connection(user:)
    REDIS.hset("game_room:#{id}:connected_at", user.id.to_s, Time.current.iso8601)
    REDIS.expire("game_room:#{id}:connected_at", REDIS_TTL)
  end

  def last_connected_at(user:)
    ts = REDIS.hget("game_room:#{id}:connected_at", user.id.to_s)
    ts ? Time.parse(ts) : nil
  end

  # ── Destruction ───────────────────────────────────────────────────────────

  def destroy
    REDIS.del("game_room:#{id}", "game_room:#{id}:participants", "game_room:#{id}:connected_at")
    REDIS.srem(INDEX_KEY, id)
  end
end
