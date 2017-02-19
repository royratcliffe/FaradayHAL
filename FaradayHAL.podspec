Pod::Spec.new do |spec|
  spec.name = 'FaradayHAL'
  spec.version = '0.3.3'
  spec.summary = 'Middleware components for encoding and decoding HAL'
  spec.description = <<-DESCRIPTION
  FaradayHAL provides Faraday middleware components for encoding and decoding
  hypertext-application-language requests and responses.
  DESCRIPTION
  spec.homepage = 'https://github.com/royratcliffe/FaradayHAL'
  spec.license = { type: 'MIT', file: 'MIT-LICENSE.txt' }
  spec.author = { 'Roy Ratcliffe' => 'roy@pioneeringsoftware.co.uk' }
  spec.source = {
    git: 'https://github.com/royratcliffe/FaradayHAL.git',
    tag: spec.version.to_s }
  spec.source_files = 'Sources/**/*.{swift,h}'
  spec.platform = :ios, '9.0'
  spec.requires_arc = true
  spec.dependency 'Faraday', '~> 0.6.0'
  spec.dependency 'HypertextApplicationLanguage', '~> 1.0.0'
end
