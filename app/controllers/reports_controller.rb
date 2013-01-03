class ReportsController < ApplicationController
  def index
    @reports = Report.all
  end

  def new

  end

  def parse

    if params[:message]
      message = params[:message][:text]

      # select report
      start_index = (message =~ /From:	 Fleet Command/)
      report = message[start_index..message.length]

      # user parsing
      matched_string = report.match(/\[(\d+):(\d+):(\d+)\](?:\s*)\(Player: ([^)]*)\)(?:\s*)at (\d+-\d+ \d+:\d+:\d+)/)

      report_ins = nil
      if matched_string
        planet = Planet.where(:galaxy => matched_string[1].to_i, :system => matched_string[2].to_i, :planet_number => matched_string[3].to_i).first
        unless planet
          planet = Planet.new(:galaxy => matched_string[1].to_i, :system => matched_string[2].to_i, :planet_number => matched_string[3].to_i)
        end

        # user matching
        user = User.where(:ogame_id => matched_string[4]).first
        unless user
          user = User.new(:ogame_id => matched_string[4])
          user.save
        end
        planet.user = user
        planet.save

        report_ins = Report.where(:planet_id => planet.id, :time => Time.parse((Time.now - 14.hours).year.to_s+"-"+matched_string[5]) + 14.hours).first
        unless report_ins
          report_ins = Report.new
          report_ins.planet = planet
        end
        report_ins.time = Time.parse((Time.now - 14.hours).year.to_s+"-"+matched_string[5]) + 14.hours
        report_ins.message = message
        report_ins.save
      end

      parse_all report, report_ins
      redirect_to planets_path

      #resource_strings = []
      #resource_titles.each do |resource_title|
      #  matched_string = report.match(/#{resource_title}:(?:\s*)((\d|[.])+)(?:\s*)/)
      #  if matched_string
      #    resource_strings[resource_titles.index resource_title] = matched_string[1]
      #  end
      #end
      #
      #resources = []
      #resource_strings.each do |resource_string|
      #  resources.push resource_string.gsub(/[.]/,"").to_i
      #end
      #
      #resources.each do |resource|
      #  result += "#{resource_titles[resources.index resource]} : #{resource}"
      #end

# fleets parsing
#      if report.include? "fleets"
#        fleet_titles = ["Small Cargo", "Large Cargo", "Light Fighter", "Heavy Fighter", "Cruiser", "Battleship", "Recycler", "Espionage Probe"]
#        fleets = []
#        fleet_titles.each do |fleet_title|
#          matched_string = report.match(/#{fleet_title}(?:\s*)((\d|[.])+)(?:\s*)/)
#          if matched_string
#            fleets[fleet_titles.index fleet_title] = matched_string[1].to_i
#          else
#            fleets[fleet_titles.index fleet_title] = 0
#          end
#        end
#
#
#        fleets.each do |fleet|
#          result += "#{fleet_titles[fleets.index fleet]} : #{fleet}"
#        end
#      end


      #render :json => matched_string

    end

  end

  def re_parse
    Report.where("message IS NOT NULL").find_each do |report_ins|
      message = report_ins.message

      # select report
      start_index = (message =~ /From:	 Fleet Command/)
      report = message[start_index..-1]

      matched_string = report.match(/\[(\d+):(\d+):(\d+)\](?:\s*)\(Player: ([^)]*)\)(?:\s*)at (\d+-\d+ \d+:\d+:\d+)/)

      if matched_string
        planet = Planet.where(:galaxy => matched_string[1].to_i, :system => matched_string[2].to_i, :planet_number => matched_string[3].to_i).first
        unless planet
          planet = Planet.new(:galaxy => matched_string[1].to_i, :system => matched_string[2].to_i, :planet_number => matched_string[3].to_i)
        end

        # user matching
        user = User.where(:ogame_id => matched_string[4]).first
        unless user
          user = User.new(:ogame_id => matched_string[4])
          user.save
        end
        planet.user = user
        planet.save

        report_ins.time = Time.parse((Time.now - 14.hours).year.to_s+"-"+matched_string[5]) + 14.hours
        report_ins.planet = planet
        report_ins.message = message
        report_ins.save
      end

      parse_all report, report_ins
    end

    redirect_to planets_path
  end

  def destroy
    @report = Report.find(params[:id])

    @report.report_resources.destroy_all
    @report.report_researches.destroy_all
    @report.report_buildings.destroy_all
    @report.report_fleets.destroy_all
    @report.report_defenses.destroy_all

    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  def parse_all report, report_ins
    # resources parsing
    Resource.find_each do |resource|
      matched_string = report.match(/#{resource.keyword}:(?:\s*)((\d|[.])+)(?:\s*)/)
      if matched_string

        value = matched_string[1].gsub(/[.]/,"").to_i
        if value > 0

          report_resource = ReportResource.where(:report_id => report_ins.id, :resource_id => resource.id).first
          unless report_resource
            report_resource = ReportResource.new
            report_resource.report = report_ins
            report_resource.resource = resource
          end
          report_resource.value = value
          report_resource.save
        end
      end
    end


    # buildings parsing
    is_building_parsed = false
    Building.find_each do |building|
      matched_string = report.match(/#{building.keyword}(?:\s*)((\d|[.])+)(?:\s*)/)
      if matched_string
        is_building_parsed = true

        value = matched_string[1].gsub(/[.]/,"").to_i
        if value > 0

          report_building = ReportBuilding.where(:report_id => report_ins.id, :building_id => building.id).first
          unless report_building
            report_building = ReportBuilding.new
            report_building.report = report_ins
            report_building.building = building
          end
          report_building.value = value
          report_building.save
        end
      end
    end

    report_ins.include_buildings = is_building_parsed
    report_ins.save


    # fleets parsing
    if report.include? "fleets"
      Fleet.find_each do |fleet|
        matched_string = report.match(/#{fleet.keyword}(?:\s*)((\d|[.])+)(?:\s*)/)
        if matched_string
          value = matched_string[1].gsub(/[.]/,"").to_i
          if value > 0

            report_fleet = ReportFleet.where(:report_id => report_ins.id, :fleet_id => fleet.id).first
            unless report_fleet
              report_fleet = ReportFleet.new
              report_fleet.report = report_ins
              report_fleet.fleet = fleet
            end
            report_fleet.value = value
            report_fleet.save
          end
        end
      end

      report_ins.include_fleets = true
      report_ins.save
    end



    # defenses parsing
    if report.include? "Defense"
      Defense.find_each do |defense|
        matched_string = report.match(/#{defense.keyword}(?:\s*)((\d|[.])+)(?:\s*)/)
        if matched_string
          value = matched_string[1].gsub(/[.]/,"").to_i
          if value > 0

            report_defense = ReportDefense.where(:report_id => report_ins.id, :defense_id => defense.id).first
            unless report_defense
              report_defense = ReportDefense.new
              report_defense.report = report_ins
              report_defense.defense = defense
            end
            report_defense.value = value
            report_defense.save
          end
        end
      end

      report_ins.include_defenses = true
      report_ins.save
    end




  end
end



