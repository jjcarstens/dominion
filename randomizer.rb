#!/usr/bin/env ruby
# require 'bundler/setup'
# $:.unshift( ::File.join(__FILE__, '..', '..', 'lib') )
require "thor"
require "json"
require "pry"

class Randomizer < Thor

  desc "generate", "Generate random dominion deck"
  option :amount, aliases: "-l", required: true, type: :numeric, default: 10
  option :adventures, :aliases => '-a', :type => :boolean
  option :alchemy, :aliases => '-y', :type => :boolean
  option :base, :aliases => '-b', :type => :boolean
  option :cornucopia, :aliases => '-c', :type => :boolean
  option :dark_ages, :aliases => '-d', :type => :boolean
  option :empires, :aliases => '-e', :type => :boolean
  option :guilds, :aliases => '-g', :type => :boolean
  option :hinterlands, :aliases => '-h', :type => :boolean
  option :intrigue, :aliases => '-i', :type => :boolean
  option :nocturne, :aliases => '-n', :type => :boolean
  option :prosperity, :aliases => '-p', :type => :boolean
  option :renaissance, :aliases => '-r', :type => :boolean
  option :seaside, :aliases => '-s', :type => :boolean
  def generate
    decks = ::JSON.parse(File.read("/Users/jonjon/repos/dominion/decks_with_costs.json"))
    potentials = []

    options.each do |set_name, _val|
      next if set_name == "amount"
      if decks[set_name] && decks[set_name]["cards"]
        decks[set_name]["cards"].each { |card, cost| potentials << {card => cost} }
        potentials.shuffle!
      else
        puts "#{set_name} may be missing or have no cards listed!!"
      end
    end

    chosen = potentials.flatten.shuffle.sample(options.amount)
    chosen_keys = chosen.map(&:keys).flatten

    if chosen_keys.any? { |c| c =~ /young witch/i }
      bane_card = nil
      while bane_card.nil? || potentials.count == 0
        popped = potentials.shuffle.pop
        card = popped.keys.first
        cost = popped.values.first

        if !chosen_keys.include?(card) && (cost == "2" || cost == "3")
          bane_card = card
        end
      end
    end

    decks.each do |deck_name, deck|
      deck_printed = false

      deck["cards"].each do |card, cost|
        next unless chosen_keys.include?(card) || card == bane_card
        puts "\n#{deck["emoji"]}  \033[#{deck["color"]}m#{deck_name.upcase}\033[0m" unless deck_printed
        deck_printed = true

        if card == bane_card
          puts "    #{card} -> BANE CARD"
        else
          puts "    #{card}"
        end
      end
    end
  end
end

::Randomizer.start
