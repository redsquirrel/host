require 'noam_server/config'

module NoamServer
  class Orchestra
    attr_reader :players, :events

    def self.instance
      @instance ||= self.new
    end

    def initialize
      @players = {}
      @connections = {}
      @events = {}
      @play_callbacks = []
      @register_callbacks = []
      @unregister_callbacks = []
    end

    def register(player_connection, player)
      spalla_id = player.spalla_id

      players[spalla_id] = player
      @connections[spalla_id] = player_connection

      fired = []
      player.hears.each do |event|
        @events[event] ||= {}
        fired << @events[event][spalla_id]
        @events[event][spalla_id] = player_connection
      end
      fired.compact.uniq.each(&:terminate)

      player.plays.each do |event|
        @events[event] ||= {}
      end

      @register_callbacks.each do |callback|
        callback.call(player)
      end
    end

    def fire_player(spalla_id)
      player = players.delete(spalla_id)
      @connections.delete(spalla_id)

      @events.each do |event, actors|
        actors.delete(spalla_id)
      end

      @unregister_callbacks.each do |callback|
        callback.call(player)
      end
    end

    def event_names
      @events.keys.sort
    end

    def play(event, value, player_id)
      player = players[player_id]

      player.learn_to_play(event) unless player.nil?
      player.last_activity = DateTime.now unless player.nil?

      @events[event] ||= {}

      # We need to dup here since #fire_player can mutate the underlying hashes
      @events[event].dup.each do |id, player_connection|
        begin
          player_connection.hear(player_id, event, value)
        rescue => e
          CONFIG[:logger].warn "Error trying to notify player (#{id}) of event (#{event}). Firing them."
          fire_player(id)
        end
      end

      @play_callbacks.each do |callback|
        callback.call(event, value, player)
      end
    end

    def on_register(&callback)
      @register_callbacks << callback
    end

    def on_unregister(&callback)
      @unregister_callbacks << callback
    end

    def on_play(&callback)
      @play_callbacks << callback
    end

    def players_for(spalla_ids)
      spalla_ids ||= []
      valid_players = players.select{ |spalla_id, player| spalla_ids.include? spalla_id }.values
    end

    def spalla_ids
      players.values.map( &:spalla_id )
    end

    def deployable_spalla_ids
      players.values.select( &:deployable? ).map( &:spalla_id )
    end
  end
end
