# frozen_string_literal: true

module ApplicationHelper
  def all_admin_region_volunteer_tuples(whom)
    admin_rids = whom.assignments.collect{ |a| a.admin ? a.region.id : nil }.compact
    Volunteer.all.collect{ |v|
      v_rids = v.regions.collect{ |r| r.id }
      !(admin_rids & v_rids).empty? ? [v.name+' ['+v.regions.collect{ |r| r.name }.join(',')+']', v.id] : nil
    }.compact
  end

  def readable_time_until shift
    ret = shift.when.strftime('%a %b %e') + ' ('
    ret += 'today' if shift.when.today?
    ret += distance_of_time_in_words(Time.zone.today, shift.when) + ' ago' if shift.when.past?
    ret += distance_of_time_in_words(Time.zone.today, shift.when) + ' from now' if shift.when.future?
    ret += ')'
    ret += " <br>between #{readable_start_time(shift.schedule_chain)} and #{readable_stop_time(shift.schedule_chain)}" if shift.schedule_chain
    ret.html_safe
  end

  def readable_start_time schedule
    schedule = schedule.schedule_chain if schedule.is_a? Schedule
    str = 'unknown'
    str = schedule.detailed_start_time.to_s(:clean_time) unless schedule.detailed_start_time.nil?
    str
  end

  def readable_stop_time schedule
    schedule = schedule.schedule_chain if schedule.is_a? Schedule
    str = 'unknown'
    str = schedule.detailed_stop_time.to_s(:clean_time) unless schedule.detailed_stop_time.nil?
    str
  end

  def readable_pickup_timespan schedule
    return nil if schedule.nil?
    schedule = schedule.schedule_chain if schedule.is_a? Schedule
    str = 'Pickup '
    str+= 'irregularly ' if schedule.irregular
    str+= 'every '+Date::DAYNAMES[schedule.day_of_week]+' ' if schedule.weekly? and !schedule.day_of_week.nil?
    str+= 'on '+schedule.detailed_date.to_s(:long_ordinal)+' ' if schedule.one_time?
    str+= 'between '
    str+= readable_start_time schedule
    str+= ' and '
    str+= readable_stop_time schedule
    str
  end
end
