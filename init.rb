require 'pry'

Redmine::Plugin.register :list_issues do
  name 'List Issues'
  author 'Grzegorz Łuszczek'
  #description 'Thisggplugin overrides default include in Wiki'
  version '1.0.0'

  module WikiMacros
    Redmine::WikiFormatting::Macros.register do
      desc "List issues"
      macro :list_issues do |obj, args|
        name, *rest = args
        version = @project.versions.where( name: name ).first!
        groupped = rest.group_by { |attr| ((tmp = attr[0...3]) == "max" || tmp == "min") ? tmp : "eq" }
        query = Hash[*(groupped["eq"] || []).flat_map {|q| k,v = q.split("="); [k,v]}]
        smaller = (groupped['max'] || []).collect { |attr| attr[4..-1].gsub("=", " <= ") }.join(" AND ")
        greater = (groupped['min'] || []).collect { |attr| attr[4..-1].gsub("=", " >= ") }.join(" AND ")

        content_tag(:ul) do
          version.fixed_issues.where(query).where(smaller).where(greater).collect do |issue|
            content_tag(:li, issue.subject)
          end.join("\n").html_safe
        end
      end
    end
  end
end
