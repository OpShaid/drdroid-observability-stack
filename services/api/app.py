from flask import Flask, jsonify, request
import time
import random
from metrics import setup_metrics, track_request
from tracing import init_tracer, trace_request
import logging

app = Flask(__name__)


setup_metrics(app)
tracer = init_tracer('api-service')
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/health')
def health():
    
    return jsonify({"status": "healthy", "service": "api"}), 200

@app.route('/api/users', methods=['GET'])
@track_request('get_users')
@trace_request(tracer)
def get_users():
    
    logger.info("Fetching users")
    time.sleep(random.uniform(0.05, 0.2)) 
    
    return jsonify({
        "users": [
            {"id": 1, "name": "Alice"},
            {"id": 2, "name": "Bob"}
        ]
    }), 200

@app.route('/api/checkout', methods=['POST'])
@track_request('checkout')
@trace_request(tracer)
def checkout():
   
    logger.info("Processing checkout")
    
    
    if random.random() < 0.05:  
        logger.error("Checkout failed - payment processing error")
        return jsonify({"error": "Payment failed"}), 500
    
    
    time.sleep(random.uniform(0.1, 0.8))
    
    amount = random.uniform(10, 500)
    logger.info(f"Checkout successful: ${amount:.2f}")
    
    return jsonify({
        "success": True,
        "amount": amount,
        "order_id": random.randint(1000, 9999)
    }), 200

@app.route('/api/signup', methods=['POST'])
@track_request('signup')
@trace_request(tracer)
def signup():
    
    logger.info("New user signup")
    time.sleep(random.uniform(0.1, 0.3))
    
    return jsonify({"user_id": random.randint(1000, 9999)}), 201

@app.route('/error')
def trigger_error():
    
    logger.error("Intentional error triggered")
    return jsonify({"error": "Internal server error"}), 500

@app.route('/slow')
@track_request('slow_endpoint')
@trace_request(tracer)
def slow_endpoint():
    
    logger.warning("Slow endpoint called")
    time.sleep(random.uniform(2, 5)) 
    return jsonify({"message": "This was slow"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
