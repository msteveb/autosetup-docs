include Nanoc::Helpers::Blogging
include Nanoc::Helpers::Breadcrumbs
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Capturing
include Nanoc::Helpers::Rendering

def pretty_time(time)
  time.strftime("%A, %d %B %Y") if !time.nil?
end

def featured_count
  @config[:featured_count].to_i
end

# Takes an item link name like '/' or '/developer/' and returns the matching item
def item_of(id)
	if id == '/'
		id = '/index'
	end
	if %r{^/.+/$}.match(id)
		id = id.chop
	end
	return @items.find { |i| i.identifier.without_ext == id }
end

def item_linkname(item)
	if item.identifier.without_ext == '/index'
		return '/'
	end
	return item.identifier.without_ext + '/'
end

def derive_created_at(item)
	item[:date] || Date.strptime(item.identifier.without_ext.to_s.split('/')[-1], "%Y-%m-%d")
end

def is_article(item)
	item[:kind] == "article" || %r{^/articles/.+$}.match(item.identifier)
end

def show_related_topics(item)
	result = "<ul>\n"
	@item[:seealso].each do |b|
		ii = @items.find { |i| i.identifier.without_ext + '/' == b }
		if ii
			result << "<li>" << link_to(ii[:label] || ii[:title], b) << "</li>\n"
		end
	end
	result <<= "</ul>\n"
end

def dputs(str)
	if $debug
		puts str
	end
end
