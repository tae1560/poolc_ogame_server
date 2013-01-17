class ReportsController < ApplicationController
  before_filter :authenticate_user

  def index
    @reports = Report.all
  end

  def new

  end

  def parse

    if params[:message]
      message = params[:message][:text]

      # select report

      start_index_array = message.enum_for(:scan,/Resources\s*on/).map { Regexp.last_match.begin(0) }

      start_index_array.each do |start_index|
        temp_message = message[start_index..message.length]
        end_index_array = temp_message.enum_for(:scan,/Attack/).map { Regexp.last_match.begin(0) }

        if end_index_array.size > 0

          report = message[start_index..start_index+end_index_array[0]]

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
            report_ins.report_text = report
            report_ins.save
          end

          parse_all report, report_ins

        end
      end

      redirect_to planets_path



      #render :json => matched_string

    end

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


    # researches parsing
    if report.include? "Research"
      Research.find_each do |research|
        matched_string = report.match(/#{research.keyword}(?:\s*)((\d|[.])+)(?:\s*)/)
        if matched_string
          value = matched_string[1].gsub(/[.]/,"").to_i
          if value > 0

            report_research = ReportResearch.where(:report_id => report_ins.id, :research_id => research.id).first
            unless report_research
              report_research = ReportResearch.new
              report_research.report = report_ins
              report_research.research = research
            end
            report_research.value = value
            report_research.save
          end
        end
      end

      report_ins.include_researches = true
      report_ins.save
    end


  end

  def re_parse
    # report 정리
    Planet.all do |planet|
      last_report = planet.reports.order(:time).last
      fleet_report = planet.reports.where(:include_fleets => true).order(:time).last
      defense_report = planet.reports.where(:include_defenses => true).order(:time).last
      research_report = planet.reports.where(:include_researches => true).order(:time).last
      building_report = planet.reports.where(:include_buildings => true).order(:time).last

      planet.reports.each do |report|
        if report.id == last_report.id or report.id == fleet_report.id or report.id == defense_report.id or report.id == research_report.id or report.id == building_report.id
        else
          report.delete
        end
      end
    end

    Report.where("message IS NOT NULL").find_each do |report_ins|
      report = report_ins.report_text

      if report
        # user parsing
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
          report_ins.report_text = report
          report_ins.save
        end

        parse_all report, report_ins
      end
    end

    redirect_to planets_path
  end

  def re_parse_with_messages
    Report.where("message IS NOT NULL").find_each do |report_ins|
      message = report_ins.message

      # select report
      start_index_array = message.enum_for(:scan,/Resources\s*on/).map { Regexp.last_match.begin(0) }

      start_index_array.each do |start_index|
        temp_message = message[start_index..message.length]
        end_index_array = temp_message.enum_for(:scan,/Attack/).map { Regexp.last_match.begin(0) }

        if end_index_array.size > 0

          report = message[start_index..start_index+end_index_array[0]]

          # user parsing
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
            report_ins.report_text = report
            report_ins.save
          end

          parse_all report, report_ins

        end
      end

    end

    redirect_to planets_path
  end
end




