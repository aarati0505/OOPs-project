# Python + Flask Backend Server
# Alternative to Node.js implementation

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)
app.config['JSON_SORT_KEYS'] = False

CORS(app)  # Allow Flutter app to make requests
jwt = JWTManager(app)

# Import routes
from routes import auth_routes, products_routes, orders_routes

# Register blueprints (routes)
app.register_blueprint(auth_routes.bp, url_prefix='/v1/auth')
app.register_blueprint(products_routes.bp, url_prefix='/v1/products')
app.register_blueprint(orders_routes.bp, url_prefix='/v1/orders')

# Health check
@app.route('/health')
def health():
    return jsonify({'status': 'OK', 'message': 'Server is running'})

if __name__ == '__main__':
    app.run(debug=True, port=3000)

