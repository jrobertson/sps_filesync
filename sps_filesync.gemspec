Gem::Specification.new do |s|
  s.name = 'sps_filesync'
  s.version = '0.1.0'
  s.summary = 'Used in conjunction with the drb_fileserver_plus gem to ' + 
      'synchronise files between 2 or more nodes on the network.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/sps_filesync.rb']
  s.add_runtime_dependency('sps-sub', '~> 0.3', '>=0.3.6')
  s.add_runtime_dependency('drb_fileclient', '~> 0.4', '>=0.4.2')
  s.signing_key = '../privatekeys/sps_filesync.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/sps_filesync'
end
