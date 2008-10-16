#!/usr/bin/env ruby
require 'rubygems'
require 'rake/clean'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = "dm-simpledb"
  s.version = "0.2"
  s.author = "Edward Ocampo-Gooding"
  s.email = "edward@videojuicer.com"
  s.homepage = "http://github.com/edward/dm-simpledb"
  s.platform = Gem::Platform::RUBY
  s.summary = "A DataMapper adapter for SimpleDB"
  s.files = %w( LICENSE README Rakefile ) + FileList["{spec,lib}/**/*"].exclude("rdoc").to_a
  s.require_path = "lib"
  s.autorequire = "dm-simpledb"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("dm-core", ">= 0.9.5")
  s.add_dependency("amazon_sdb", ">= 0.6.7")
end

Rake::GemPackageTask.new(spec) do |package|
  package.need_tar = true
end

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  # t.rcov = true
end