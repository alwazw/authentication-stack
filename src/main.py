#!/usr/bin/env python3
"""
Docker Stack Deployment Service
A Flask application to manage the Docker stack deployment
"""

from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import subprocess
import os
import json
import time
import logging

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
STACK_DIR = '/app/docker-stack'
COMPOSE_FILE = os.path.join(STACK_DIR, 'docker-compose.yml')

@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')

@app.route('/api/status')
def get_status():
    """Get the status of all services"""
    try:
        result = subprocess.run(
            ['docker', 'compose', '-f', COMPOSE_FILE, 'ps', '--format', 'json'],
            capture_output=True,
            text=True,
            cwd=STACK_DIR
        )
        
        if result.returncode == 0:
            services = []
            for line in result.stdout.strip().split('\n'):
                if line:
                    services.append(json.loads(line))
            return jsonify({'status': 'success', 'services': services})
        else:
            return jsonify({'status': 'error', 'message': result.stderr})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/api/deploy', methods=['POST'])
def deploy_stack():
    """Deploy the Docker stack"""
    try:
        # Pull latest images
        logger.info("Pulling latest Docker images...")
        pull_result = subprocess.run(
            ['docker', 'compose', '-f', COMPOSE_FILE, 'pull'],
            capture_output=True,
            text=True,
            cwd=STACK_DIR
        )
        
        if pull_result.returncode != 0:
            return jsonify({'status': 'error', 'message': f'Pull failed: {pull_result.stderr}'})
        
        # Deploy stack
        logger.info("Deploying Docker stack...")
        deploy_result = subprocess.run(
            ['docker', 'compose', '-f', COMPOSE_FILE, 'up', '-d'],
            capture_output=True,
            text=True,
            cwd=STACK_DIR
        )
        
        if deploy_result.returncode == 0:
            return jsonify({'status': 'success', 'message': 'Stack deployed successfully'})
        else:
            return jsonify({'status': 'error', 'message': deploy_result.stderr})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/api/stop', methods=['POST'])
def stop_stack():
    """Stop the Docker stack"""
    try:
        result = subprocess.run(
            ['docker', 'compose', '-f', COMPOSE_FILE, 'down'],
            capture_output=True,
            text=True,
            cwd=STACK_DIR
        )
        
        if result.returncode == 0:
            return jsonify({'status': 'success', 'message': 'Stack stopped successfully'})
        else:
            return jsonify({'status': 'error', 'message': result.stderr})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/api/logs/<service>')
def get_logs(service):
    """Get logs for a specific service"""
    try:
        result = subprocess.run(
            ['docker', 'compose', '-f', COMPOSE_FILE, 'logs', '--tail', '100', service],
            capture_output=True,
            text=True,
            cwd=STACK_DIR
        )
        
        if result.returncode == 0:
            return jsonify({'status': 'success', 'logs': result.stdout})
        else:
            return jsonify({'status': 'error', 'message': result.stderr})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/api/config')
def get_config():
    """Get current configuration"""
    try:
        with open(os.path.join(STACK_DIR, '.env'), 'r') as f:
            env_content = f.read()
        
        return jsonify({
            'status': 'success',
            'env_config': env_content,
            'services': [
                'traefik',
                'postgresql',
                'redis',
                'authentik-server',
                'authentik-worker',
                'pgadmin'
            ]
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

