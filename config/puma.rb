DEFAULT_PORT = 9292
DEFAULT_THREADS = 3

port Integer(ENV.fetch('PORT', DEFAULT_PORT))
thread_count = Integer(ENV.fetch('MAX_THREADS', DEFAULT_THREADS))
threads thread_count, thread_count
environment ENV.fetch('RACK_ENV', 'development')
