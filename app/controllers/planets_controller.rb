class PlanetsController < ApplicationController
  #before_filter :authenticate_user

  def index
    # current user information
    unless session[:start_planet]
      session[:start_planet] = {:galaxy => 1, :system => 52, :position => 11}
    end

    unless session[:speed]
      session[:speed] = 20000
    end

    @start_planet = session[:start_planet][:galaxy].to_s + ":" + session[:start_planet][:system].to_s + ":" + session[:start_planet][:position].to_s
    @speed = session[:speed]

    @planets = Planet.all

    @planets_information = []
    @planets.each do |planet|
      if planet.reports.size == 0
        next
      end

      planet_information = {}
      report = planet.reports.last
      planet_information['planet'] = planet
      planet_information['ogame_id'] = planet.user.ogame_id
      planet_information['coordinate'] = planet.coordinate

      unless report
        report = Report.new
      end

      time = report.time ? report.time : Time.now
      planet_information['metal'] = report.get_resource_value "Metal"
      planet_information['crystal'] = report.get_resource_value "Crystal"
      planet_information['deuterium'] = report.get_resource_value "Deuterium"
      planet_information['energy'] = report.get_resource_value "Energy"
      planet_information['need_small_cargo'] = ((planet_information['metal'] + planet_information['crystal'] + planet_information['deuterium']) / 2.0 / 5000).ceil
      planet_information['elapsed_time'] = ((Time.now - time)/60/60).round

      # building
      building_report = planet.reports.where(:include_buildings => true).last
      unless building_report
        building_report = Report.new
      end
      planet_information['Metal Mine'] = building_report.get_building_value "Metal Mine"
      planet_information['Crystal Mine'] = building_report.get_building_value "Crystal Mine"
      planet_information['Deuterium Synthesizer'] = building_report.get_building_value "Deuterium Synthesizer"

      # time
      # =round((10 + 3500 * sqrt(10 * (2700 + 95 * abs(M8-$AC$1)) / $AF$1))/60/60,2)
      flight_duration = 10 + 3500 * Math.sqrt(10 * (2700 + 95 * (session[:start_planet][:system]-planet.system).abs) / session[:speed])
      arrival_time = Time.now + flight_duration.seconds
      planet_information['arrival_time'] = arrival_time

      # predict resource
      #=round(R5+AM5*($B$1-$E$1)/1000)
      # cur + lv * hours / 1000
      metal_per_hour = 30*planet_information['Metal Mine']*(1.1 ** planet_information['Metal Mine'])
      crystal_per_hour = 30*planet_information['Crystal Mine']*(1.1 ** planet_information['Crystal Mine'])
      deuterium_per_hour = 30*planet_information['Deuterium Synthesizer']*(1.1 ** planet_information['Deuterium Synthesizer'])
      predict_time = Time.now - time + flight_duration.seconds

      planet_information['next_metal'] = (planet_information['metal'] + metal_per_hour * predict_time/60/60).round
      planet_information['next_crystal'] = (planet_information['crystal'] + crystal_per_hour * predict_time/60/60).round
      planet_information['next_deuterium']  = (planet_information['deuterium'] + deuterium_per_hour * predict_time/60/60).round
      planet_information['next_need_small_cargo'] = ((planet_information['next_metal'] + planet_information['next_crystal'] + planet_information['next_deuterium']) / 2.0 / 5000).ceil

      # links
      planet_information['attack_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=1&am202=#{planet_information['next_need_small_cargo']}"
      planet_information['espionage_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=6&am210=1"
      planet_information['detail_espionage_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=6&am210=11"


      # fleets
      planet_information['number_of_fleets'] = 0
      fleet_report = planet.reports.where(:include_fleets => true).last
      unless fleet_report
        fleet_report = Report.new
      end
      fleet_report.report_fleets.each do |report_fleet|
        planet_information['number_of_fleets'] += report_fleet.value
      end
      planet_information['fleet_kinds'] = fleet_report.fleets.size



      # defenses
      planet_information['number_of_defenses'] = 0
      defense_report = planet.reports.where(:include_defenses => true).last
      unless defense_report
        defense_report = Report.new
      end
      defense_report.report_defenses.each do |report_defense|
        unless report_defense.defense.keyword.include? "Missiles"
          planet_information['number_of_defenses'] += report_defense.value
        end
      end

      # filtering
      #if planet_information['energy'] != "-" and planet_information['energy'] > 3000
        @planets_information.push planet_information
      #end
    end

    # sort
    @planets_information = @planets_information.sort_by { |k| k['next_need_small_cargo']}
    @planets_information = @planets_information.reverse
  end

  def show
    @planet = Planet.find(params[:id])

    # fleets
    @fleet_report = @planet.reports.where(:include_fleets => true).last
    unless @fleet_report
      @fleet_report = Report.new
    end

    # defenses
    @defense_report = @planet.reports.where(:include_defenses => true).last
    unless @defense_report
      @defense_report = Report.new
    end

  end

  def update
    # 공격한 카소 공격 기록 등록
    #@planet = Planet.find(params[:id])
    #report = @planet.reports.last
    #
    #@attack = Attack.new
    #@attack.target_planet = @planet
    #
    #render :json => @attack

    #if report
    #  report.update_resource_value "Metal", (report.get_resource_value "Metal") / 2
    #  report.update_resource_value "Crystal", (report.get_resource_value "Crystal") / 2
    #  report.update_resource_value "Deuterium", (report.get_resource_value "Deuterium") / 2
    #end

    #redirect_to :back
  end

  def planet_config
    configs = params[:configs]

    matched_string = configs[:start_planet].match(/(\d+):(\d+):(\d+)/)

    if matched_string
      galaxy = matched_string[1].to_i # 1~9
      system = matched_string[2].to_i # 1~499
      position = matched_string[3].to_i # 1~15

      if galaxy.between?(1,9) and system.between?(1,499) and position.between?(1,15)
        session[:start_planet] = {:galaxy => galaxy, :system => system, :position => position}
      end
    end

    session[:speed] = configs[:speed].to_i

    redirect_to :back
  end
end
