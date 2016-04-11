class GemVersion
  def initialize(file_path)
    @file_path = file_path
  end

  def gems
    File.read(@file_path).each_line.each_with_object([]) do |line, array|
      line =~ /([\w-]*) \((.*)\)/
      next if $2.blank?
      gem_name = $1
      versions = $2.split(', ')

      next if gem_name !~ /-/
      array.concat versions.map {|v| [gem_name, v]}
    end
  end
end
