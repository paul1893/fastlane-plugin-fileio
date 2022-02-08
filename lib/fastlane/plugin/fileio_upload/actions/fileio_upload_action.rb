require 'fastlane/action'
require_relative '../helper/fileio_upload_helper'

module Fastlane
  module Actions

    module SharedValues
      UPLOAD_FILE_RESULT = :UPLOAD_FILE_RESULT
      UPLOAD_FILE_LINK = :UPLOAD_FILE_LINK
    end

    class FileioUploadAction < Action
      def self.run(params)
        Actions.verify_gem!('rest-client')
        require 'rest-client'
        
        file = params[:file]
        expiration = params[:expiration]
        apiKey = params[:apiKey]
        maxDownloads = params[:maxDownloads]
        autoDelete = params[:autoDelete]

        UI.message "Start uploading: #{file} with #{expiration} expiration"

        headers = {
          "Authorization"=>"Bearer #{apiKey}"
        }
        payload = {
                    :multipart => true,
                    :file => File.new("#{file}", 'rb')
                  }
        if (expiration != false)
        then
          payload[:expires] = "#{expiration}"
        end
        if (maxDownloads != 0)
        then
          payload[:maxDownloads] = maxDownloads
        end
        if (autoDelete != false)
        then
          payload[:autoDelete] = autoDelete
        end
        
        upload = RestClient.post(
          "https://file.io/",
          payload,
          headers
        )
        upload_result = JSON.parse(upload)
        UI.message "#{upload_result}"

        Actions.lane_context[SharedValues::UPLOAD_FILE_RESULT] = upload_result['success']
        Actions.lane_context[SharedValues::UPLOAD_FILE_LINK] = upload_result['link']

        upload_result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload file to file.io and share the link with anyone!"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        # Define all options your action supports.
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       description: "The file you want to upload",
                                       verify_block: proc do |value|
                                          UI.user_error!("No file to upload, pass using `file: 'my-file.txt'` or couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :expiration,
                                       description: "Duration before expiration",
                                       is_string: true,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :apiKey,
                                       description: "ApiKey to use to upload large file",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :maxDownloads,
                                       description: "Max downloads authorized",
                                       default_value: 0,
                                       type: Integer),
          FastlaneCore::ConfigItem.new(key: :autoDelete,
                                       description: "Should auto delete after max downloads reached",
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        [
          ['UPLOAD_FILE_RESULT', 'Result of the upload success or failure'],
          ['UPLOAD_FILE_LINK', 'Link where the file is accessible after upload']
        ]
      end

      def self.return_value
        "Link where the file is accessible after upload"
      end

      def self.authors
        ["https://github.com/paul1893"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
