from jaeger_client import Config
from flask import request
from functools import wraps
import logging

def init_tracer(service_name):
    
    config = Config(
        config={
            'sampler': {
                'type': 'const',
                'param': 1,
            },
            'logging': True,
            'reporter_batch_size': 1,
        },
        service_name=service_name,
        validate=True,
    )
    return config.initialize_tracer()

def trace_request(tracer):
    
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            with tracer.start_span(f.__name__) as span:
                span.set_tag('http.method', request.method)
                span.set_tag('http.url', request.url)
                
                try:
                    result = f(*args, **kwargs)
                    status_code = result[1] if isinstance(result, tuple) else 200
                    span.set_tag('http.status_code', status_code)
                    return result
                except Exception as e:
                    span.set_tag('error', True)
                    span.log_kv({'event': 'error', 'message': str(e)})
                    raise
                    
        return wrapped
    return decorator
