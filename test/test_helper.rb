$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gcode_vm'

PROJECT_ROOT = Pathname.new('../../').expand_path(__FILE__)

require 'minitest/autorun'
