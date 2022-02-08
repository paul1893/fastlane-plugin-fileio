describe Fastlane::Actions::FileioUploadAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The fileio_upload plugin is working!")

      Fastlane::Actions::FileioUploadAction.run(nil)
    end
  end
end
