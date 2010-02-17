class GmailSender
  class MessageStreamWriter
    ATTACHMENT_READ_PORTION = 150360 # you may change this, but must be multiply to 3

    attr_reader :attachments

    def initialize(sender_email)
      @sender_email = sender_email
      @attachments = []
      @boundary = rand(2**256).to_s(16)
    end

    def write(msg_stream, to, subject, content)
      write_headers(msg_stream, to, subject)
      write_content(msg_stream, content)
      write_attachments(msg_stream)
    end

    private
    def write_headers(msg_stream, to, subject)
      msg_stream.puts "From: #{@sender_email}"
      msg_stream.puts "To: #{to}"
      msg_stream.puts "Subject: #{subject}"
      unless @attachments.empty?
        msg_stream.puts 'MIME-Version: 1.0'
        msg_stream.puts %{Content-Type: multipart/mixed; boundary="#{@boundary}"}
      end
      msg_stream.puts
    end

    def write_content(msg_stream, content)
      unless @attachments.empty?
        msg_stream.puts "--#{@boundary}" unless @attachments.empty?
        msg_stream.puts 'Content-Type: text/plain'
      end

      msg_stream.puts content
    end

    def write_attachments(msg_stream)
      @attachments.each do |file|
        msg_stream.puts "--#{@boundary}"
        msg_stream.puts %{Content-Type: application/octet-stream; name="#{File.basename(file)}"}
        msg_stream.puts %{Content-Disposition: attachment; filename="#{File.basename(file)}"}
        msg_stream.puts 'Content-Transfer-Encoding: base64'
        msg_stream.puts "Content-ID: <#{File.basename(file)}>"
        msg_stream.puts
        File.open(file) do |fd|
          msg_stream.puts Base64.encode64(fd.read(ATTACHMENT_READ_PORTION)) until fd.eof?
        end
      end
    end
  end
end
