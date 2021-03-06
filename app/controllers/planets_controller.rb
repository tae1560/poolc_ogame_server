#coding : UTF-8
class PlanetsController < ApplicationController
  #before_filter :authenticate_user
  before_filter :authenticate_user

  def index
    # current user information
    #unless session[:start_planet]
    #  session[:start_planet] = {:galaxy => 1, :system => 52, :position => 11}
    #end

    unless @current_user.planets.size > 0
      redirect_to edit_user_path(@current_user), :notice => "행성이 하나 이상 있어야 합니다."
      return
    end

    unless session[:start_planet_id]
      session[:start_planet_id] = @current_user.planets.first.id
    end

    unless session[:speed]
      session[:speed] = 20000
    end

    @start_planet =  Planet.find(session[:start_planet_id])
    @speed = session[:speed]

    @planets = Planet.all


    @planets_informations = {"inactive users" => [], "active users" => [], "protected users" => []}

    @planets.each do |planet|
      if planet.reports.size == 0
        next
      end

      planet_information = {}
      report = planet.reports.order(:time).last
      planet_information['user'] = planet.user
      planet_information['planet'] = planet
      planet_information['ogame_id'] = planet.user.ogame_id
      planet_information['galaxy'] = planet.galaxy
      planet_information['system'] = planet.system
      planet_information['planet_number'] = planet.planet_number
      planet_information['coordinate'] = planet.coordinate
      planet_information['galaxy_address'] = "http://uni1.ogame.us/game/index.php?page=galaxy&no_header=1&galaxy=#{planet.galaxy}&system=#{planet.system}&planet=#{planet.planet_number}"

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
      building_report = planet.reports.where(:include_buildings => true).order(:time).last
      unless building_report
        building_report = Report.new
      else
        planet_information['building_report'] = building_report
      end
      planet_information['Metal Mine'] = building_report.get_building_value "Metal Mine"
      planet_information['Crystal Mine'] = building_report.get_building_value "Crystal Mine"
      planet_information['Deuterium Synthesizer'] = building_report.get_building_value "Deuterium Synthesizer"

      # time
      flight_duration = @start_planet.flight_duration planet, session[:speed]
      arrival_time = Time.now + flight_duration.seconds
      planet_information['arrival_time'] = arrival_time

      # predict resource
      #=round(R5+AM5*($B$1-$E$1)/1000)
      # cur + lv * hours / 1000
      metal_per_hour = 30*planet_information['Metal Mine']*(1.1 ** planet_information['Metal Mine'])
      crystal_per_hour = 20*planet_information['Crystal Mine']*(1.1 ** planet_information['Crystal Mine'])
      deuterium_per_hour = 10*planet_information['Deuterium Synthesizer']*(1.1 ** planet_information['Deuterium Synthesizer'])
      predict_time = Time.now - time + flight_duration.seconds

      planet_information['next_metal'] = (planet_information['metal'] + metal_per_hour * predict_time/60/60).round
      planet_information['next_crystal'] = (planet_information['crystal'] + crystal_per_hour * predict_time/60/60).round
      planet_information['next_deuterium']  = (planet_information['deuterium'] + deuterium_per_hour * predict_time/60/60).round

      # attacks
      planet.attacks.where("time > ?", Time.now).each do |attack|
        planet_information['is_attacking'] = true
        planet_information['next_metal'] -= attack.metal
        planet_information['next_crystal'] -= attack.crystal
        planet_information['next_deuterium'] -= attack.deuterium
      end

      planet_information['next_need_small_cargo'] = ((planet_information['next_metal'] + planet_information['next_crystal'] + planet_information['next_deuterium']) / 2.0 / 5000).ceil

      # links
      planet_information['attack_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=1&am202=#{planet_information['next_need_small_cargo']}"
      planet_information['espionage_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=6&am210=1"
      planet_information['detail_espionage_address'] = "http://uni1.ogame.us/game/index.php?page=fleet1&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&mission=6&am210=11"
      #planet_information['mini_espionage_address'] = "http://uni1.ogame.us/game/index.php?page=minifleet&ajax=1&mission=6&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&shipCount=1"
      planet_information['mini_espionage_address'] = "send_epionage.html?galaxy=#{planet_information['galaxy']}&system=#{planet_information['system']}&position=#{planet_information['planet_number']}"
      #planet_information['detail_espionage_address'] = "http://uni1.ogame.us/game/index.php?page=minifleet&ajax=1&mission=6&galaxy=#{planet.galaxy}&system=#{planet.system}&position=#{planet.planet_number}&type=1&shipCount=11"

      # fleets
      planet_information['number_of_fleets'] = 0
      fleet_report = planet.reports.where(:include_fleets => true).order(:time).last
      unless fleet_report
        fleet_report = Report.new
      else
        planet_information['fleet_report'] = fleet_report
      end
      fleet_report.report_fleets.each do |report_fleet|
        planet_information['number_of_fleets'] += report_fleet.value
      end
      planet_information['fleet_kinds'] = fleet_report.fleets.size



      # defenses
      planet_information['number_of_defenses'] = 0
      defense_report = planet.reports.where(:include_defenses => true).order(:time).last
      unless defense_report
        defense_report = Report.new
      else
        planet_information['defense_report'] = defense_report
      end
      defense_report.report_defenses.each do |report_defense|
        unless report_defense.defense.keyword.include? "Missiles"
          planet_information['number_of_defenses'] += report_defense.value
        end
      end

      # filtering
      #if planet_information['energy'] != "-" and planet_information['energy'] > 3000
      #if planet_information['elapsed_time'] < 36
      if planet.user.is_status "i"
        @planets_informations["inactive users"].push planet_information
      elsif planet.user.is_status "b" or planet.user.is_status "v" or planet.user.is_status "A" or planet.user.is_status "n"
        @planets_informations["protected users"].push planet_information
      else
        @planets_informations["active users"].push planet_information
      end

      #end
    end

    # sort
    if params[:arrange_type]
      session[:arrange_type] = params[:arrange_type].to_i
    end

    if session[:arrange_type]
      @planets_informations.each do |array_name, array|
        if session[:arrange_type] == 0
          array.sort_by! { |k| k['ogame_id'].downcase}
        elsif session[:arrange_type] == 1
          array.sort_by! { |k| k['galaxy'] * 100000 + k['system'] * 100 + k['planet_number']}
        elsif session[:arrange_type] == 2
          array.sort_by! { |k| k['next_metal']}
          array.reverse!
        elsif session[:arrange_type] == 3
          array.sort_by! { |k| k['next_crystal']}
          array.reverse!
        elsif session[:arrange_type] == 4
          array.sort_by! { |k| k['next_deuterium']}
          array.reverse!
        elsif session[:arrange_type] == 5
          array.sort_by! { |k| k['energy']}
          array.reverse!
        elsif session[:arrange_type] == 6
          array.sort_by! { |k| k['next_need_small_cargo']}
          array.reverse!
        elsif session[:arrange_type] == 7
          array.sort_by! { |k| k['elapsed_time']}
        elsif session[:arrange_type] == 8
        elsif session[:arrange_type] == 9
        elsif session[:arrange_type] == 10
        elsif session[:arrange_type] == 11
          array.sort_by! { |k| k['number_of_fleets']}
          array.reverse!
        elsif session[:arrange_type] == 12
          array.sort_by! { |k| k['number_of_defenses']}
          array.reverse!
        elsif session[:arrange_type] == 13
        end
      end
    end
  end

  def show
    @planet = Planet.find(params[:id])

    @last_report = @planet.reports.order(:time).last
    unless @last_report
      @last_report = Report.new
    end

    @fleet_report = @planet.reports.where(:include_fleets => true).order(:time).last
    @defense_report = @planet.reports.where(:include_defenses => true).order(:time).last
    @research_report = @planet.reports.where(:include_researches => true).order(:time).last
    @building_report = @planet.reports.where(:include_buildings => true).order(:time).last

    # report 정리
    @planet.reports.each do |report|
      if report.id == @last_report.id or (@fleet_report and report.id == @fleet_report.id) or (@defense_report and report.id == @defense_report.id) or (@research_report and report.id == @research_report.id) or (@building_report and report.id == @building_report.id)
      else
        report.delete
      end
    end

    @params = params
  end

  def update
    @attack = Attack.new
    @attack.target_planet = Planet.find(params[:id])
    @attack.start_planet = Planet.find(params[:planet][:start_planet])
    @attack.time = Time.parse(params[:planet][:arrival_time])

    if Attack.where(:target_planet_id => @attack.target_planet.id, :start_planet_id => @attack.start_planet, :time => @attack.time).first
      @attack = Attack.where(:target_planet_id => @attack.target_planet.id, :start_planet_id => @attack.start_planet, :time => @attack.time).first
    end

    @attack.metal = params[:resources][:metal].to_i
    @attack.crystal = params[:resources][:crystal].to_i
    @attack.deuterium = params[:resources][:deuterium].to_i


    if @attack.save
      redirect_to :back
    else
      redirect_to :back
    end
    #render :json => params
    #render :json => @attack

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

  def update_multiple
    params[:planets].each do |k,v|
      if v[:check] == "1"
        @attack = Attack.new
        @attack.target_planet = Planet.find(k)
        @attack.start_planet = Planet.find(v[:planets][:start_planet])
        @attack.time = Time.parse(v[:planets][:arrival_time])

        if Attack.where(:target_planet_id => @attack.target_planet.id, :start_planet_id => @attack.start_planet, :time => @attack.time).first
          @attack = Attack.where(:target_planet_id => @attack.target_planet.id, :start_planet_id => @attack.start_planet, :time => @attack.time).first
        end

        @attack.metal = v[:resources][:metal].to_i
        @attack.crystal = v[:resources][:crystal].to_i
        @attack.deuterium = v[:resources][:deuterium].to_i
        @attack.save
      end
    end

    redirect_to :back
  end

  def planet_config
    configs = params[:configs]

    #render :json => params
    #return

    if params[:user][:planet_id]
      #galaxy = matched_string[1].to_i # 1~9
      #system = matched_string[2].to_i # 1~499
      #position = matched_string[3].to_i # 1~15

      session[:start_planet_id] = params[:user][:planet_id]
      #if galaxy.between?(1,9) and system.between?(1,499) and position.between?(1,15)
      #  session[:start_planet] = {:galaxy => galaxy, :system => system, :position => position}
      #end
    end

    session[:speed] = configs[:speed].to_i

    redirect_to :back
  end

  def create
    planet = Planet.where(:galaxy => params[:planet][:galaxy], :system => params[:planet][:system], :planet_number => params[:planet][:planet_number]).first
    if planet
      redirect_to :back, :notice => "해당 좌표의 행성이 이미 있습니다"
      return
    end

    @planet = Planet.new(params[:planet])
    user = User.find(params[:user][:id])
    @planet.user = user

    respond_to do |format|
      if @planet.save
        format.html { redirect_to :back, :notice => "created successfully" }
      else
        format.html { redirect_to :back, :notice => @planet.errors.full_messages}
      end
    end
  end

  def destroy
    @planet = Planet.find(params[:id])
    @planet.reports.destroy_all
    @planet.destroy

    respond_to do |format|
      format.html { render :json => "Success" }
      format.json { head :no_content }
    end
  end

  def send_epionage

  end
end
