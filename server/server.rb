require 'bundler'
Bundler.require

require 'json'

# variable to hold counter
$counter = 0

set :server, 'thin'
set :sockets, []
set :public_folder, './client'

get '/' do
    # Check if the request is a normal request
    # or a websocket request (this check can be
    # done on any route, might be a good idea to
    # have a separate route for the websocket 
    # traffic)
    if !request.websocket?
        # if its not a websocket request, serve the file
        File.read './client/index.html'
    else
        # if it is, handle the request
        request.websocket do |ws|
            # This is entered when the client first opens their connection
            ws.onopen do |msg|
                # Construct a hash to send to the client
                # includes an id for the client to keep
                # the client should include it's id in every
                # request it sends
                output = {
                    'action' => 'connect',
                    'id' => settings.sockets.length
                }
                # Convert the hash to a JSON object and send it to the client
                # {'action' => 'connect'} -> {action: 'connect'}
                ws.send output.to_json
                # Add the connection to the list of open connection
                settings.sockets << ws
            end

            ws.onmessage do |msg|
                # Convert JSON string to hash
                object = JSON.parse(msg)
                
                # Check which action the client wants performed
                case object['action']
                when 'connect'
                    p "Client: " + object['clientName'] + " has connected"
                when 'inc'
                    $counter += 1
                    # create object with the new value of counter
                    output = {
                        'action' => 'inc',
                        'number' => $counter
                    }
                    # find the connection based on the id the client
                    # sent, without id we have no chance of keeping
                    # track of our connections or telling the apart
                    settings.sockets[object['id']].send output.to_json
                end
            end

            ws.onclose do
                # delete the connection when the socket is closed
                settings.sockets.delete(ws)
            end
        end
    end
end