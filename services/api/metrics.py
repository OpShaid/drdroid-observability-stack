from prometheus_client import Counter, Histogram, Gauge, generate_latest
from flask import Response
import time
from functools import wraps


http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint']
)

revenue_total = Counter(
    'revenue_total',
    'Total revenue generated',
    ['currency']
)

user_signups_total = Counter(
    'user_signups_total',
    'Total user signups'
)

active_requests = Gauge(
    'active_requests',
    'Number of active requests'
)

database_connection_pool_usage = Gauge(
    'database_connection_pool_usage',
    'Database connection pool usage percentage'
)

def setup_metrics(app):
    
    @app.route('/metrics')
    def metrics():
        return Response(generate_latest(), mimetype='text/plain')

def track_request(endpoint_name):
    
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            active_requests.inc()
            start_time = time.time()
            
            try:
                response = f(*args, **kwargs)
                status_code = response[1] if isinstance(response, tuple) else 200
                
                
                http_requests_total.labels(
                    method='GET',
                    endpoint=endpoint_name,
                    status=status_code
                ).inc()
                
                duration = time.time() - start_time
                http_request_duration_seconds.labels(
                    method='GET',
                    endpoint=endpoint_name
                ).observe(duration)
                
               
                if endpoint_name == 'checkout' and status_code == 200:
                    if isinstance(response, tuple):
                        data = response[0].get_json()
                        revenue_total.labels(currency='USD').inc(data.get('amount', 0))
                
                if endpoint_name == 'signup' and status_code == 201:
                    user_signups_total.inc()
                
                return response
                
            finally:
                active_requests.dec()
                
        return wrapped
    return decorator
