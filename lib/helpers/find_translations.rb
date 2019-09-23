CONTENT_TOP_DIRS = %w(blog community docs download governance index webtools assets)

def find_translations(item, items)
  language_code = language_code(item)
  canonic_path = canonical_path(item)
  translation_items = items.find_all {|i| language_code(i) != language_code and canonical_path(i) == canonic_path }
  translations = translation_items.map {|i| { :path => i.identifier.to_s, :language_code => language_code(i) } }
end

def langulage_path_prefix(item)
  top_dir = item.identifier.to_s.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? '' : '/' + top_dir
end
def language_code(item)
  top_dir = item.identifier.to_s.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? 'en' : top_dir
end

def canonical_path(item)
  prefix = langulage_path_prefix(item)
  item.identifier.to_s[prefix.length..-1]
end