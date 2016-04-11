class DangerousGemValidator
  def initialize
    refresh
  end

  def invalid_gems(gems)
    _invalid_gems(gems).map do |name, number, rubygem, version|
      [name, number, version.created_at.strftime('%Y-%m-%d %H:%M:%S')]
    end
  end

  def excepted_records
    {
      rubygems_has_no_records: @rubygems_has_no_records.sort.uniq,
      rubygems_has_multiple_records: @rubygems_has_multiple_records.sort.uniq,
      versions_has_not_just_one_records: @versions_has_not_just_one_records.sort.uniq
    }
  end

  private
  def _invalid_gems(gems)
    return @invalid_gems if @invalid_gems

    @invalid_gems = gems.each_with_object([]) do |(name, number), array|
      rubygems = Rubygem.where(name: name)
      if rubygems.count == 0
        @rubygems_has_no_records << "#{name} has no record"
        next
      end

      if rubygems.count != 1
        @rubygems_has_multiple_records << "#{name} has #{rubygems.count} record(s)"
        next
      end

      rubygem = rubygems.first
      versions = rubygem.versions.where(number: number)

      case
      when versions.count == 1
        version = versions.first
      when versions.where(platform: 'ruby').exists?
        version = versions.find_by(platform: 'ruby')
      else
        @versions_has_not_just_one_records << "#{name} has #{versions.count} versions record(s) (number: #{number}, rubygem.id: #{rubygem.id})"
        next
      end

      if (Time.utc(2014, 6, 11) <= version.created_at) && (version.created_at <= Time.utc(2015, 2, 18))
        array << [name, number, rubygem, version]
      end
    end
  end

  def refresh
    @invalid_gems = nil
    @rubygems_has_no_records = []
    @rubygems_has_multiple_records = []
    @versions_has_not_just_one_records = []
  end
end
