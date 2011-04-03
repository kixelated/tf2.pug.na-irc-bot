require 'bundler/setup'
$: << '../../lib' # could cause a problem

require 'tf2pug/database'
DataMapper.finalize
