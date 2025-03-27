require 'cgi'
require 'socket'
require 'securerandom'

# Azure mappings: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=trx%2Cyaml

module Spectre
  module Reporter
    class VSTest
      def initialize config
        @config = config
        @date_format = '%FT%T.%L'
      end

      def report run_infos
        now = Time.now.getutc

        xml_str = '<?xml version="1.0" encoding="UTF-8" ?>'
        xml_str += %(<TestRun xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010">)

        started = run_infos[0].started
        finished = run_infos[-1].finished

        computer_name = Socket.gethostname

        xml_str += %(<Times start="#{started.strftime(@date_format)}" finish="#{finished.strftime(@date_format)}" />)

        # Write summary with file attachments
        xml_str += '<ResultSummary>'
        xml_str += '<ResultFiles>'
        if File.exist? @config['log_file']
          xml_str += %(<ResultFile path="#{File.absolute_path(@config['log_file'])}"></ResultFile>)
        end

        report_files = Dir[File.join(@config['out_path'], '*')]

        if report_files.any?
          report_files.each do |report_file|
            xml_str += %(<ResultFile path="#{File.absolute_path(report_file)}"></ResultFile>)
          end
        end

        xml_str += '</ResultFiles>'
        xml_str += '</ResultSummary>'

        # Write test definitions
        test_definitions = run_infos
          .sort_by { |x| x.parent.name }
          .map { |x| [SecureRandom.uuid, SecureRandom.uuid, x] }

        xml_str += '<TestDefinitions>'
        test_definitions.each do |test_id, execution_id, run_info|
          xml_str += %(<UnitTest name="#{CGI.escapeHTML get_name(run_info)}" \
            storage="#{CGI.escapeHTML(run_info.parent.file.to_s)}" id="#{test_id}">)
          xml_str += %(<Execution id="#{execution_id}" />)
          xml_str += '</UnitTest>'
        end
        xml_str += '</TestDefinitions>'

        # Write test results
        xml_str += '<Results>'
        test_definitions.each do |test_id, execution_id, run_info|
          duration_str = Time.at(run_info.finished - run_info.started).gmtime.strftime('%T.%L')

          outcome = if [:failed, :error].include? run_info.status
                      'Failed'
                    elsif run_info.status == :skipped
                      'Skipped'
                    else
                      'Passed'
                    end

          xml_str += %(<UnitTestResult executionId="#{execution_id}" \
            testId="#{test_id}" \
            testName="#{CGI.escapeHTML get_name(run_info)}" \
            computerName="#{computer_name}" \
            duration="#{duration_str}" \
            startTime="#{run_info.started.strftime(@date_format)}" \
            endTime="#{run_info.finished.strftime(@date_format)}" \
            outcome="#{outcome}">)

          if run_info.logs.any?
            xml_str += '<Output>'

            # Write log entries
            xml_str += '<StdOut>'
            log_str = ''

            if run_info.properties.count.positive?
              run_info.properties.each do |key, val|
                log_str += "#{key}: #{val}\n"
              end
            end

            if run_info.data
              data_str = run_info.data
              data_str = run_info.data.to_json unless run_info.data.is_a? String or run_info.data.is_a? Integer
              log_str += "data: #{data_str}\n"
            end

            run_info.logs.each do |timestamp, level, progname, _corr_id, message|
              log_text = ''
              begin
                log_text = message.dup.to_s
                  .gsub(/[^[:print:]\n]/, '<np>') # Replace non printable characters
                  .force_encoding('ISO-8859-1')
                  .encode!('UTF-8')
              rescue StandardError
                puts "ERROR in VSTEST - see message : #{message}"
              end

              log_str += %(#{timestamp} #{level.to_s.upcase} -- \
                #{progname}: #{CGI.escapeHTML(log_text)}\n)
            end

            xml_str += log_str
            xml_str += '</StdOut>'

            # Write error information
            if [:failed, :error].include? run_info.status
              xml_str += '<ErrorInfo>'

              if run_info.status == :failed
                xml_str += '<Message>'

                failure_message = ''

                run_info.evaluations.each do |evaluation|
                  evaluation.failures.each do |failure|
                    failure_message += "#{evaluation.desc}, but #{failure.message} "
                  end
                end

                xml_str += CGI.escapeHTML(failure_message)

                xml_str += '</Message>'
              end

              if run_info.status == :error
                error = run_info.error

                failure_message = error.message

                xml_str += '<Message>'
                xml_str += CGI.escapeHTML(failure_message)
                xml_str += '</Message>'

                stack_trace = error.backtrace.join "\n"

                xml_str += '<StackTrace>'
                xml_str += CGI.escapeHTML(stack_trace)
                xml_str += '</StackTrace>'
              end

              xml_str += '</ErrorInfo>'
            end

            xml_str += '</Output>'
          end

          xml_str += '</UnitTestResult>'
        end
        xml_str += '</Results>'

        # End report
        xml_str += '</TestRun>'

        FileUtils.mkdir_p(@config['out_path'])

        file_path = File.join(@config['out_path'], "spectre-vstest_#{now.strftime('%s')}.trx")

        File.write(file_path, xml_str)
      end

      private

      def get_name run_info
        parent = run_info.parent
        "[#{run_info.name}] #{parent.full_desc}"
      end
    end
  end
end
