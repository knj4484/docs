CONTENT_TOP_DIRS = %w(blog community docs download governance index webtools assets)

def find_translations(item, items)
  top_dir = item.path.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? 'en' : top_dir
  canonical_path = language_code == 'en' ? item.path : item.path[3..-1]
  translation_items = items.find_all {|i| get_language_code(i) != language_code and get_canonical_path(i) == canonical_path }
  translations = translation_items.map {|i| { :path => i.identifier.to_s, :language_code => get_language_code(i) } }
  language_code == 'en' ? translations : translations << { :path => canonical_path, :language_code => 'en' }
end

def langulage_path_prefix(item)
  top_dir = item.path.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? '' : '/' + top_dir
end
def get_language_code(item)
  item.identifier.to_s[1..2]
end

def get_canonical_path(item)
  item.identifier.to_s[3..-1]
end