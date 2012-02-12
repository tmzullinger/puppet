require 'spec_helper'
require 'semver'

describe SemVer do
  it "should produce expected ranges" do
    tests = {
      '1.2.3'           => SemVer.new('v1.2.3-') ..  SemVer.new('v1.2.3'),
      '>1.2.3'          => SemVer.new('v1.2.4-') ..  SemVer::MAX,
      '<1.2.3'          => SemVer::MIN           ... SemVer.new('v1.2.3-'),
      '>=1.2.3'         => SemVer.new('v1.2.3-') ..  SemVer::MAX,
      '<=1.2.3'         => SemVer::MIN           ..  SemVer.new('v1.2.3'),
      '>1.2.3 <1.2.5'   => SemVer.new('v1.2.4-') ... SemVer.new('v1.2.5-'),
      '>=1.2.3 <=1.2.5' => SemVer.new('v1.2.3-') ..  SemVer.new('v1.2.5'),
      '1.2.3 - 2.3.4'   => SemVer.new('v1.2.3-') ..  SemVer.new('v2.3.4'),
      '~1.2.3'          => SemVer.new('v1.2.3-') ... SemVer.new('v1.3.0-'),
      '~1.2'            => SemVer.new('v1.2.0-') ... SemVer.new('v2.0.0-'),
      '~1'              => SemVer.new('v1.0.0-') ... SemVer.new('v2.0.0-'),
      '1.2.x'           => SemVer.new('v1.2.0')  ... SemVer.new('v1.3.0-'),
      '1.x'             => SemVer.new('v1.0.0')  ... SemVer.new('v2.0.0-'),
    }

    tests.each do |vstring, expected|
      SemVer[vstring].should == expected
    end
  end

  it "should suit up" do
    suitability = {
      [ '1.2.3',         'v1.2.2' ] => false,
      [ '>=1.2.3',       'v1.2.2' ] => false,
      [ '<=1.2.3',       'v1.2.2' ] => true,
      [ '>= 1.2.3',      'v1.2.2' ] => false,
      [ '<= 1.2.3',      'v1.2.2' ] => true,
      [ '1.2.3 - 1.2.4', 'v1.2.2' ] => false,
      [ '~1.2.3',        'v1.2.2' ] => false,
      [ '~1.2',          'v1.2.2' ] => true,
      [ '~1',            'v1.2.2' ] => true,
      [ '1.2.x',         'v1.2.2' ] => true,
      [ '1.x',           'v1.2.2' ] => true,

      [ '1.2.3',         'v1.2.3-alpha' ] => true,
      [ '>=1.2.3',       'v1.2.3-alpha' ] => true,
      [ '<=1.2.3',       'v1.2.3-alpha' ] => true,
      [ '>= 1.2.3',      'v1.2.3-alpha' ] => true,
      [ '<= 1.2.3',      'v1.2.3-alpha' ] => true,
      [ '>1.2.3',        'v1.2.3-alpha' ] => false,
      [ '<1.2.3',        'v1.2.3-alpha' ] => false,
      [ '> 1.2.3',       'v1.2.3-alpha' ] => false,
      [ '< 1.2.3',       'v1.2.3-alpha' ] => false,
      [ '1.2.3 - 1.2.4', 'v1.2.3-alpha' ] => true,
      [ '1.2.3 - 1.2.4', 'v1.2.4-alpha' ] => true,
      [ '1.2.3 - 1.2.4', 'v1.2.5-alpha' ] => false,
      [ '~1.2.3',        'v1.2.3-alpha' ] => true,
      [ '~1.2.3',        'v1.3.0-alpha' ] => false,
      [ '~1.2',          'v1.2.3-alpha' ] => true,
      [ '~1.2',          'v2.0.0-alpha' ] => false,
      [ '~1',            'v1.2.3-alpha' ] => true,
      [ '~1',            'v2.0.0-alpha' ] => false,
      [ '1.2.x',         'v1.2.3-alpha' ] => true,
      [ '1.2.x',         'v1.3.0-alpha' ] => false,
      [ '1.x',           'v1.2.3-alpha' ] => true,
      [ '1.x',           'v2.0.0-alpha' ] => false,

      [ '1.2.3',         'v1.2.3' ] => true,
      [ '>=1.2.3',       'v1.2.3' ] => true,
      [ '<=1.2.3',       'v1.2.3' ] => true,
      [ '>= 1.2.3',      'v1.2.3' ] => true,
      [ '<= 1.2.3',      'v1.2.3' ] => true,
      [ '1.2.3 - 1.2.4', 'v1.2.3' ] => true,
      [ '~1.2.3',        'v1.2.3' ] => true,
      [ '~1.2',          'v1.2.3' ] => true,
      [ '~1',            'v1.2.3' ] => true,
      [ '1.2.x',         'v1.2.3' ] => true,
      [ '1.x',           'v1.2.3' ] => true,

      [ '1.2.3',         'v1.2.4' ] => false,
      [ '>=1.2.3',       'v1.2.4' ] => true,
      [ '<=1.2.3',       'v1.2.4' ] => false,
      [ '>= 1.2.3',      'v1.2.4' ] => true,
      [ '<= 1.2.3',      'v1.2.4' ] => false,
      [ '1.2.3 - 1.2.4', 'v1.2.4' ] => true,
      [ '~1.2.3',        'v1.2.4' ] => true,
      [ '~1.2',          'v1.2.4' ] => true,
      [ '~1',            'v1.2.4' ] => true,
      [ '1.2.x',         'v1.2.4' ] => true,
      [ '1.x',           'v1.2.4' ] => true,
    }

    suitability.each do |arguments, expected|
      range, vstring = arguments
      actual = SemVer[range] === SemVer.new(vstring)
      actual.should == expected
    end
  end
end
