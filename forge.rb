require 'uri'


def decode_session(str)
  Marshal.load(URI.decode_www_form_component(str).unpack("m").first)
end

puts decode_session()
