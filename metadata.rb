name 'automount'
maintainer 'Nephila Graphic'
maintainer_email 'ted@nephilagraphic.com'
license 'Apache 2.0'
description 'Installs/Configures automount'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

%w(ubuntu).each do |os|
  supports os
end
