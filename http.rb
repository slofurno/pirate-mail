require 'yaml'
require 'aws-sdk'
require 'thread'
require 'socket'

def start_worker(requests, i)

    creds = YAML.load(File.read('secrets/aws.yml'))
    client = Aws::SES::Client.new(
        access_key_id: creds['access_key_id'],
        secret_access_key: creds['secret_access_key'],
        region: creds['region'],
    )

    loop do
        sock = requests.deq
        handle_request(sock, client, i)
    end

end

def handle_request(sock, client, i)

    while true
        line = sock.gets
        #puts "line length #{line.length}"
        break if line.nil? || line.length == 2
    end

    response = "hi from worker #{i}" 
    sock.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n" +
               "\r\n"
    sock.print response
    sock.close
    resp = client.send_email({
        source: "noreply@gdf3.com",
        destination: {
            to_addresses: ["slofurno@gmail.com"],
        },
        message: {
            subject: {
                data: "sent from worker #{i}",
            },
            body: {
                text: {
                    data: "HEY< THIS IS FROM RUBY",
                },
            },
        },
    })

end

threads = []
requests = Queue.new

16.times do |i|
    threads.push(Thread.new { start_worker(requests, i) })
end

server = TCPServer.open(555)

loop do
    sock = server.accept
    requests.push(sock)
    #handle_request(sock, client, 1)
end
