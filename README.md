# zeromq-matlab

[ZeroMQ] mex bindings for MATLAB. This version is known to work with:

* ZMQ 4.0.8 on Debian 8 with MATLAB 2016a.
* ZMQ 4.1.5 on Mac OS X 10.11.6 with MATLAB 2016a.

## Dependencies

Requires ZeroMQ, naturally. Try `sudo apt-get install libzmq3-dev`,
`brew install zeromq` or similar.

## Installation

To build, run `make`.
To test, run `make test` if MATLAB can be called from the command line.

## API Examples

```matlab
p = zmq('publish', 'tcp://*:1337');
s = zmq('subscribe', 'tcp://127.0.0.1:1337');

% for tcp on the localhost, it's necessary to poll once before sending anything
% see: https://github.com/smcgill3/zeromq-matlab/issues/4
zmq('poll', 1); % 1 msec

while 1
    nbytes_sent = zmq('send', p, uint8('hello world!')');
    id = zmq('poll', -1); % block
    [data, has_more] = zmq('recv', id(1));
    fprintf('%s\n', char(data'));
end
```

[ZeroMQ]: http://zeromq.org/