% (c) 2015 Stephen McGill
% (c) 2016 Joseph E. O'Doherty
% MATLAB script to test zeromq-matlab

function test_zmq()

    clear all;

	rng('shuffle');

    TEST_IPC = true;
    TEST_TCP = true;
    TEST_INPROC = true;

if ispc
    disp('ZMQ IPC not supported on windows. Skipping IPC test...');
    TEST_IPC = false;
end

if TEST_IPC
    disp('Testing IPC');
    p1 = zmq( 'publish',   'ipc:///tmp/matlab.zmq' );
    s1 = zmq( 'subscribe', 'ipc:///tmp/matlab.zmq' );

    if  do_string_test(p1, s1) && ...
        do_uint8_test(p1, s1) && ...
        do_double_test(p1, s1)
        disp('IPC PASS');
    else
        disp('IPC FAIL');
    end
end

if TEST_TCP
    disp('Testing TCP');
    port = 2048 + randi(255);
    p1 = zmq( 'publish',   sprintf('tcp://*:%d', port) );
    s1 = zmq( 'subscribe', sprintf('tcp://127.0.0.1:%d', port) );

    if  do_string_test(p1, s1) && ...
        do_uint8_test(p1, s1) && ...
        do_double_test(p1, s1)
        disp('TCP PASS');
    else
        disp('TCP FAIL');
    end
end

if TEST_INPROC
    disp('Testing INPROC');
    x = randi(255);
    p1 = zmq( 'publish',   sprintf('inproc://foo-%d', x) );
    s1 = zmq( 'subscribe', sprintf('inproc://foo-%d', x) );

    if  do_string_test(p1, s1) && ...
        do_uint8_test(p1, s1) && ...
        do_double_test(p1, s1)
        disp('INPROC PASS');
    else
        disp('INPROC FAIL');
    end
end

if ~ispc
    quit
end

end

function outcome = do_string_test(p, s)

    % for tcp on the localhost, it's necessary to poll once before sending
    % see: https://github.com/smcgill3/zeromq-matlab/issues/4
    zmq('poll', 1);

    outcome = true;

    disp('=> string test');
    str = 'hello world!';
    d = uint8(str)';
    n = zmq('send', p, d);
    fprintf('   Sent "%s" (%d bytes)\n', str, n);

    idx = zmq('poll', 1);
    if (numel(idx)==0)
       disp('No data!');
       outcome = false;
    end

    for i=1:numel(idx)
        if idx(i) == s
            [recv_data, has_more] = zmq('recv', idx(i));
            fprintf('   Recv "%s" (%d bytes)\n', char(recv_data), numel(recv_data));
            fprintf('   More? %d\n', has_more);
            if numel(d) ~= numel(recv_data)
                outcome = false;
            else
                if ~all(recv_data==d)
                    outcome = false;
                end
            end
        end
    end
end

function outcome = do_uint8_test(p, s)

    % for tcp on the localhost, it's necessary to poll once before sending
    % see: https://github.com/smcgill3/zeromq-matlab/issues/4
    zmq('poll', 1);

    outcome = true;

    disp('=> uint8 test');
    d = uint8(randi(255));
    n = zmq('send', p, d);
    fprintf('   Sent "%d" (%d bytes)\n', d, n);

    idx = zmq('poll', 1);
    if (numel(idx)==0)
       disp('No data!')
       outcome = false;
    end

    for i=1:numel(idx)
        if idx(i) == s
            [recv_data, has_more] = zmq('recv', idx(i));
            fprintf('   Recv "%d" (%d bytes)\n', recv_data, numel(recv_data));
            fprintf('   More? %d\n', has_more);
            if numel(d) ~= numel(recv_data)
                outcome = false;
            else
                if ~all(recv_data==d)
                    outcome = false;
                end
            end
        end
    end
end

function outcome = do_double_test(p, s)

    % for tcp on the localhost, it's necessary to poll once before sending
    % see: https://github.com/smcgill3/zeromq-matlab/issues/4
    zmq('poll', 1);

    outcome = true;

    disp('=> double test');
    d = randn(1);
    n = zmq('send', p, d);
    fprintf('   Sent "%f" (%d bytes)\n', d, n);

    idx = zmq('poll', 1);
    if (numel(idx)==0)
       disp('No data!');
       outcome = false;
    end

    for i=1:numel(idx)
        if idx(i) == s
            [recv_data, has_more] = zmq('recv', idx(i));
            x = typecast(recv_data, 'double');
            fprintf('   Recv "%f" (%d bytes)\n', x, numel(recv_data));
            fprintf('   More? %d\n', has_more);
            if numel(d) ~= numel(x)
                outcome = false;
            else
                if ~all(x==d)
                    outcome = false;
                end
            end
        end
    end
end
