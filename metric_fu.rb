# encoding: utf-8
#
# This file is part of the metrics repository. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module MetricFu
  def self.custom_directories
    rv = ENV["MF_SOURCES"]

    if rv then
      rv = rv.split(":") if rv.index(":")
      rv = [rv] if !rv.is_a?(Array)
    end

    rv
  end

  def self.root_directory
    Dir.pwd
  end

  class CaneGenerator
    def emit
      command = %Q{mf-cane#{abc_max_param}#{style_measure_param}#{no_doc_param}#{no_readme_param}#{directory_globs_params}}
      mf_debug "** #{command}"
      @output = `#{command}`
    end

    def directory_globs_params
      if options[:dirs_to_cane]
        globs = "{#{options[:dirs_to_cane].join(",")}}/**/*.rb"
        " --abc-glob \"#{globs}\" --style-glob \"#{globs}\""
      else
        ""
      end
    end
  end

  class RailsBestPracticesGenerator
    def emit
      mf_debug "** Rails Best Practices"
      path = (MetricFu.custom_directories || ["."]).first
      analyzer = ::RailsBestPractices::Analyzer.new(path, { 'silent' => true })
      analyzer.analyze
      @output = analyzer.errors
    end
  end
end

MetricFu::Configuration.run do |config|
  config.configure_metrics.each do |metric|
    enabled_metrics = [:cane, :flog, :flay, :reek, :roodi, :rails_best_practices, :saikuro]
    metric.enabled = enabled_metrics.include?(metric.name)
  end

  config.configure_metric(:cane) do |metric|
    metric.dirs_to_cane = MetricFu.custom_directories if MetricFu.custom_directories
    metric.line_length = 160
    metric.no_doc = "y"
    metric.no_readme = "y"
  end

  config.configure_metric(:flog) do |metric|
    metric.dirs_to_flog = MetricFu.custom_directories if MetricFu.custom_directories
  end

  config.configure_metric(:flay) do |metric|
    metric.dirs_to_flay = MetricFu.custom_directories if MetricFu.custom_directories
  end

  config.configure_metric(:reek) do |metric|
    metric.dirs_to_reek = MetricFu.custom_directories if MetricFu.custom_directories
    metric.config_file_pattern = MetricFu.root_directory + "/metrics/reek.yml"
  end

  config.configure_metric(:roodi) do |metric|
    metric.dirs_to_roodi = MetricFu.custom_directories if MetricFu.custom_directories
    metric.roodi_config = MetricFu.root_directory + "/metrics/roodi.yml"
  end

  config.configure_metric(:saikuro) do |metric|
    metric.input_directory = MetricFu.custom_directories
    metric.warn_cyclo = 0
    metric.error_cyclo = 6
  end
end