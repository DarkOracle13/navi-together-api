# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task default: :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/integration/api_spec.rb'
end

desc 'Test Integration with the API'
Rake::TestTask.new(:function) do |t|
  t.pattern = 'spec/integration/*.rb'
  t.warning = false
end

desc 'Test models specs only'
Rake::TestTask.new(:model) do |t|
  t.pattern = 'spec/unit/*.rb'
  t.warning = false
end

desc 'Test environment specs only'
Rake::TestTask.new(:envspec) do |t|
  t.pattern = 'spec/env_spec.rb'
  t.warning = false
end

desc 'Run both unit and security specs'
task specs: %i[function model envspec]

desc 'Runs rubocop on tested code'
task style: %i[spec audit] do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task release?: %i[spec style audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do # rubocop:disable Metrics/BlockLength
  task :load do
    require_app(nil) # load nothing by default
    require 'sequel'
    Sequel.extension :migration
    @app = Cryal::Api
  end

  task :load_models do
    require_app('models')
  end

  desc 'Run migrations'
  task migrate: %i[load print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(@app.DB, 'app/db/migrations')
  end

  desc 'Destroy data in database; maintain tables'
  task delete: :load_models do
    Cryal::Project.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task drop: :load do
    if @app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{Cryal::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  desc 'Delete all data'
  task reset_seeds: %i[load load_models] do
    @app.DB[:schema_seeds].delete if @app.DB.tables.include?(:schema_seeds)
    Cryal::Account.dataset.destroy
    Cryal::Room.dataset.destroy
    @app.DB[:sqlite_sequence].where(name: 'locations').delete
    @app.DB[:sqlite_sequence].where(name: 'user_rooms').delete
  end

  desc 'Seed the db with data'
  task seed: %i[load load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(@app.DB, 'app/db/seeds')
  end

  desc 'Delete data and reseed'
  task reseed: %i[load reset_seeds seed]
end

namespace :newkey do
  task(:load_libs) { require_app('lib', config: false) }

  desc 'Create sample cryptographic key for database'
  task :db => :load_libs do
    puts "DB_KEY: #{SecureDB.generate_key}"
  end

  desc 'Create sample cryptographic key for tokens and messaging'
  task :msg => :load_libs do
    require_app('lib', config: false)
    puts "MSG_KEY: #{AuthToken.generate_key}"
  end

  desc 'Create sample sign/verify keypair for signed communication'
  task :signing => :load_libs do
    keypair = SignedRequest.generate_keypair

    puts "SIGNING_KEY: #{keypair[:signing_key]}"
    puts " VERIFY_KEY: #{keypair[:verify_key]}"
  end
end

