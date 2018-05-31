
function message = cnt()

    host = '140.112.62.11';
    port = 7676;
    
    import java.net.Socket
    import java.io.*
    
    input_socket = [];
    message      = [];

    %======= Establish Connection ========%
    
    while true
        
        try
            %fprintf(1, 'Retry %d connecting to %s:%d\n', ...
            %        retry, host, port);

            % throws if unable to connect
            input_socket = Socket(host, port);

            % get a buffered data input stream from the socket
            input_stream   = input_socket.getInputStream;
            d_input_stream = DataInputStream(input_stream);
            
            output_stream  = input_socket.getOutputStream;
            d_output_stream = DataOutputStream(output_stream);

            %fprintf(1, 'Connected to server\n');
            
            fprintf('connected.\n')
            break;
            
        catch exception
            if ~isempty(input_socket)
                input_socket.close;
            end
            
            %fprintf(1,'Error: %s\n',getReport(exception));

            % pause before retrying
              pause(0.1);
        end
    end
    
    %===========================%

    % read data from the socket - wait a short time first
    pause(0.5);
    bytes_available = input_stream.available;
    %fprintf(1, 'Reading %d bytes\n', bytes_available);

    message = zeros(1, bytes_available, 'uint8');
    for i = 1:bytes_available
        message(i) = d_input_stream.readByte;
    end

    fprintf(char(message));

    d_output_stream.writeBytes(char('msg from client.'));
    d_output_stream.flush;

    %===========================%
    
    % cleanup
    input_socket.close;
    
end